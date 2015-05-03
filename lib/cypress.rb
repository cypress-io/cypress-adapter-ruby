module Cypress
  def self.configuration
    @configuration ||= Cypress::Configuration.new
  end

  def self.configure
    yield configuration if block_given?
  end
end
