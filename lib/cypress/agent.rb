require 'socket.io-client-simple'
module Cypress
  class Agent
    def start!
      @socket = SocketIO::Client.connect(Cypress.configuration.url)

      @socket.on :"remote:request" do |id, message, args|
        puts "id:#{id} | msg: #{message} | args: #{args}"
      end
    end
  end
end
