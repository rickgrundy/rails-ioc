require File.expand_path("../../spec_helper.rb", __FILE__)

describe RailsIOC::Singleton do
  class TestClass
    attr_reader :text
    def initialize(text)
      @text = text
    end
  end
  
  it "always returns the same instance once build has been called" do
    singleton = RailsIOC::Singleton.new(TestClass, ["I am a singleton"])
    singleton.build.text.should == "I am a singleton"
    singleton.build.should === singleton.build
  end
end