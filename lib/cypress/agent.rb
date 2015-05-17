require 'socket.io-client-simple'

module Cypress
  class Agent
    def initialize
      @socket = SocketIO::Client::Simple::Client.new(Cypress.configuration.url)
      @dispatcher = Cypress::Dispatcher.new
    end

    def dispatch(message)
      puts "dispatching"
      @dispatcher.dispatch(message)
    end

    def reconnect
      @socket.connect
    end

    def start!
      # Doesn't close over ivars, must be instance_eval/execing
      socket = @socket
      agent = self

      @socket.on :connect do
        begin
          socket.emit('remote:connected')
        rescue => e
          puts "#{e}"
        end
        puts "Connected: #{socket}"
      end

      @socket.connect

      @socket.on :"remote:request" do |id, message, args|
        puts "id:#{id} | msg: #{message} | args: #{args}"
        msg = { id: id, message: message, args: args }

        response = agent.dispatch(msg)

        socket.emit('remote:response', id, response)
      end

      @socket.on :disconnect do
        puts "socket disconnected"
      end
    end
  end
end

module Cypress
  class Dispatcher
    def initialize
      @strategy = Cypress::Strategy::Transaction.new
    end

    def dispatch(message)
      puts "in dispatch #{message}"
      msg = message[:message]
      args = message[:args]

      response = {}

      case msg
      when :before, :before_each, :after, :after_each
        @strategy.in
      else
        puts "running user hook #{msg}"
        response = run_user_hook(msg, args)
      end

      response
    end

    def run_user_hook(name, args)
      begin
        Cypress.world.execute_hook(name.to_sym, args) ||
          { __error: "No handler registered for #{name}" }
      rescue => e
        { __error: e.message, __stack: e.backtrace.join("\n") }
      end
    end
  end
end

module Cypress
  module Strategy
    # HACK!
    class Transaction
      def in
        ActiveRecord::Base.connection.execute('BEGIN')
      end

      def out
        ActiveRecord::Base.connection.execute('ROLLBACK')
      end
    end

    class DbCleaner
      def in
        ::DatabaseCleaner.start
      end

      def out
        ::DatabaseCleaner.clean
      end
    end
  end
end
