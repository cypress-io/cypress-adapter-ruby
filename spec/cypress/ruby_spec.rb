require 'spec_helper'

describe Cypress::Ruby do
  it 'has a version number' do
    expect(Cypress::Ruby::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end
