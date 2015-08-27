require 'cypress/strategy'

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
        logs = Cypress.logger.with_logs do
          response = run_user_hook(msg, args)
        end
        response[:__logs] = logs
      end

      response
    end

    def run_user_hook(name, args)
      begin
        response = Cypress.world.execute_hook(name.to_sym, args)
        if response
          { response: response }
        else
          { __error: "No handler registered for #{name}", __name: "NoRegisteredHook" }
        end
      rescue => e
        { __error: e.message, __stack: e.backtrace.join("\n"), __name: e.class.to_s }
      end
    rescue => e
      puts "Failed to run user hook #{e}"
      puts "#{e.backtrace.join("\n")}"
      raise
    end
  end
end
