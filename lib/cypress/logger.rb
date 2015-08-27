require 'logger'

module Cypress
  class Logger < ::Logger
    REGEX = /\x1B\[([0-9]{1,3}((;[0-9]{1,3})*)?)?[m|K]/
    def initialize
      @stored = []
    end

    def format(message)
      message.gsub(REGEX, '').strip
    end

    def add(severity, progname=nil, message=nil)
      @stored << self.format(message)
    end

    def with_logs
      @stored = []

      yield if block_given?

      logs = @stored
      logs.tap {
        @stored = []
      }
    end
  end

  def self.logger
    @logger ||= Cypress::Logger.new
  end
end
