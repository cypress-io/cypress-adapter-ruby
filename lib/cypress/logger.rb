module Cypress
  class Logger < ::Logger
    REGEX = /\x1B\[([0-9]{1,3}((;[0-9]{1,3})*)?)?[m|K]/
    def initialize
      @stored = []
      @formatter = self.formatter = proc do |s, d, p, m|
        puts '*****FORMATTTTTIN******'
        [
          s,
          d,
          p,
          m.gsub(REGEX, '')
        ].join(', ')
      end
    end

    def add(severity, message=nil, progname=nil)
      @stored << [ severity, message, progname ]
    end

    def with_logs
      @stored = []

      yield if block_given?

      logs = @stored
      logs.tap {
        @stored = []
      }
    end

    def formatter=(new)
      @old_formatter = @formatter
      @formatter = new
    end
  end

  def self.logger
    @logger ||= Cypress::Logger.new
  end
end
