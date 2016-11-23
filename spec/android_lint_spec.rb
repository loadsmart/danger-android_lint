require File.expand_path('../spec_helper', __FILE__)

module Danger
  describe Danger::DangerAndroidLint do
    it 'should be a plugin' do
      expect(Danger::DangerAndroidLint.new(nil)).to be_a Danger::Plugin
    end

    #
    # You should test your custom attributes and methods here
    #
    describe 'with Dangerfile' do
      before do
        @dangerfile = testing_dangerfile
        @my_plugin = @dangerfile.android_lint
      end

    end
  end
end
