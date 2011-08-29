def ignoring_warnings
  verbosity = $VERBOSE
  $VERBOSE = nil
  yield
ensure
  $VERBOSE = verbosity
end

class GlobalCounter
  def self.zero!
    @count = 0
  end
  
  def self.increment!
    @count += 1
  end
  
  def self.count
    @count
  end
end

class AdHocObject  
  def initialize
    @store = {}
  end
  
  def method_missing(name, *args)
    if name =~ /=$/
      @store[name.to_s.sub(/=|\s/, "").to_sym] = args.first
    else
      @store[name]
    end
  end
end

module FakeActionController
  class Base
    def self.before_filter(method_name); end 
  end
end

def reset_fake_dependencies!
  ignoring_warnings do
    Object.send(:const_set, :Rails, AdHocObject.new)
    Rails.application = AdHocObject.new
    Rails.application.config = AdHocObject.new
    Rails.root = File.expand_path("../fixtures", __FILE__)

    Object.send(:const_set, :ActionController, FakeActionController)
  end
end

RSpec.configure do |config|
  config.before(:each) do
    GlobalCounter.zero!
    reset_fake_dependencies!
  end
end

reset_fake_dependencies!
require File.expand_path("../../lib/rails-ioc.rb", __FILE__)