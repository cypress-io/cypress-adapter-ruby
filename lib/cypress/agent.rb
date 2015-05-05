require 'socket.io-client-simple'

module Cypress
  class Agent
    def initialize
      @socket = SocketIO::Client::Simple::Client.new(Cypress.configuration.url)
    end

    def reconnect
      @socket.connect
    end

    def start!
      # Doesn't close over ivars, must be instance_eval/execing
      socket = @socket

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
        begin
          response = Cypress.world.execute_hook(message.to_sym, args) ||
            { error: "No handler registered for #{message}" }
        rescue => e
          response = { error: e.message }
        end
        socket.emit('remote:response', id, response)
      end

      @socket.on :disconnect do
        puts "socket disconnected"
      end
    end
  end
end
