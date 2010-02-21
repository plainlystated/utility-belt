require File.join(File.dirname(__FILE__), "spec_helper")
require 'rubygems'
gem 'rspec'
require 'spec'
Platform = Module.new unless Object.const_defined?('Platform')
Net = Module.new unless Object.const_defined?('Net')

require File.expand_path(File.join(File.dirname(__FILE__),'..','lib/utility_belt'))
UtilityBelt.equip(:inspectinator)
include UtilityBelt::Inspectinator

describe "inspect!" do
  before(:all) do
    Net::HTTP = mock('HTTP') unless Net.const_defined?('HTTP')
    URI = mock('URI') unless Object.const_defined?('URI')
  end

  before(:each) do
    @page = mock('page')
    @page.stub!(:body).and_return('<xml><token>a_token</token>')
    Net::HTTP.stub!(:post_form).and_return(@page)
    URI.stub!(:parse).and_return(:parsed_uri)
    Kernel.stub!(:system)
    @obj = Object.new
  end

  it "should be available in global context" do
    inspect! Object.new
  end

  it "should POST inspect data to inspectinator.com" do
    Net::HTTP.should_receive(:post_form) do |url, post_data|
      url.should == URI.parse("http://www.inspectinator.com/parse.xml")
      post_data["i"].should match(/#<Object:.*>/)
    end
    inspect! @obj
  end

  context "opening www.inspectinator.com for the returned token" do
    it "should use 'open' for mac" do
      platform = Platform.send(:remove_const, "IMPL")
      Platform::IMPL = :macosx
      Kernel.should_receive(:system) do |show_page|
        show_page.should == "open http://www.inspectinator.com/show/a_token"
      end
      inspect! @obj
      Platform.send(:remove_const, "IMPL")
      Platform::IMPL = platform
    end

    it "should use 'start' for windows" do
      platform = Platform.send(:remove_const, "IMPL")
      Platform::IMPL = :mswin
      Kernel.should_receive(:system) do |show_page|
        show_page.should == "start http://www.inspectinator.com/show/a_token"
      end
      inspect! @obj
      Platform.send(:remove_const, "IMPL")
      Platform::IMPL = platform
    end

    it "shows an error otherwise" do
      platform = Platform.send(:remove_const, "IMPL")
      Platform::IMPL = :linux
      $stdout.should_receive(:puts).with("Sorry, don't know how to open an URL from the command line on your platform")
      inspect! @obj
      Platform.send(:remove_const, "IMPL")
      Platform::IMPL = platform
    end
  end

  it "fails gracefully" do
    @page.stub(:body).and_return("gibberish")
    $stdout.should_receive(:puts).with("Sorry, there seems to have been an error\ngibberish")
    inspect! @obj
  end
end
