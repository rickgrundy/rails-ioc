require File.expand_path("../../spec_helper.rb", __FILE__)

describe RailsIOC::Prototype do
  class TestClass
    attr_reader :text
    def initialize(text)
      @text = text
    end
  end
  
  it "builds a new instance every time build is called" do
    prototype = RailsIOC::Prototype.new(TestClass, ["I am a prototype"])
    prototype.build.text.should == "I am a prototype"
    prototype.build.should_not === prototype.build
  end
end