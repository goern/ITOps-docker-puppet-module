require 'spec_helper'
describe 'profile_dockerhost' do

  context 'with defaults for all parameters' do
    it { should contain_class('profile_dockerhost') }
  end
end
