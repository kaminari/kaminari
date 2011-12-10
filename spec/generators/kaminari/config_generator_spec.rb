require 'spec_helper'

# Generators are not automatically loaded by Rails
require 'generators/kaminari/config_generator'

describe Kaminari::Generators::ConfigGenerator do
  # Tell the generator where to put its output (what it thinks of as Rails.root)
  destination File.expand_path("../../../../tmp", __FILE__)

  before { prepare_destination }

  describe 'no arguments' do
    before { run_generator %w(products)  }

    describe 'config/initializers/kaminari_config.rb' do
      subject { file('config/initializers/kaminari_config.rb') }
      it { should exist }
      it { should contain "Kaminari.configure do |config|" }
    end

  end
end
