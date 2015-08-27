require 'cypress/agent'
require 'cypress/dispatcher'
require 'cypress/strategy'
require 'cypress/logger'
require 'cypress/configuration'

module Cypress
  def self.configuration
    @configuration ||= Cypress::Configuration.new
  end

  def self.configure
    yield configuration if block_given?
  end

  def self.agent
    @agent ||= Cypress::Agent.new
  end

  def self.start!
    agent.start!
  end

  def self.world
    @world ||= Cypress::Namespace.new
  end

  def self.define(&b)
    world.run(b)
  end
end

# Cypress.define do
#   hook :foo do
#     code code code
#   end
# end

module Cypress
  class Namespace
    def initialize
      @hooks = {}
    end

    def hook(name, &b)
      @hooks[name] = Hook.new(name, b)
    end

    def run(b)
      self.instance_exec(&b)
    end

    def execute_hook(name, args)
      puts "executing hook #{name}"
      hook = @hooks[name]
      hook.invoke(args) if hook
    end
  end

  class Hook
    attr_reader :name

    def initialize(name, block)
      @name = name
      @block = block
    end

    def invoke(args)
      @block.call(args)
    end
  end
end
