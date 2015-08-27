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

        puts "LOGS: #{response[:logs]}"
        puts response
        socket.emit('remote:response', id, response)
      end

      @socket.on :disconnect do
        puts "socket disconnected"
      end
    end
  end
end
