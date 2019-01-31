module ActionController
  class Base
    def self.before_action(method_name)
      @@before_action_method = method_name
    end
    
    def trigger_before_action!
      self.send(@@before_action_method)
    end
  end
end

class ExtendedController < ActionController::Base; end

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

Rails = AdHocObject.new
Rails.application = AdHocObject.new
Rails.application.config = AdHocObject.new
Rails.root = File.expand_path("../fixtures", __FILE__)


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

RSpec.configure do |config|
  config.before(:each) do
    GlobalCounter.zero!
  end
end

require File.expand_path("../../lib/rails-ioc.rb", __FILE__)