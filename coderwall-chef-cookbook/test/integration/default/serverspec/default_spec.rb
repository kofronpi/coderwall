require 'spec_helper'

describe 'coderwall-chef-cookbook::default' do

  # Serverspec examples can be found at
  # http://serverspec.org/resource_types.html

  describe port(3000) do
    it { should be_listening }
  end
end
