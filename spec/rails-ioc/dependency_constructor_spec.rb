require File.expand_path("../../spec_helper.rb", __FILE__)

describe RailsIOC::DependencyConstructor do
  class ConstructorTestClass
    attr_reader :foo, :bar
    def initialize(foo, bar)
      @foo, @bar = foo, bar
    end
  end
  
  it "constructs the given class" do
    instance = RailsIOC::DependencyConstructor.new(ConstructorTestClass, []).construct([123, :abc])
    instance.foo.should == 123
    instance.bar.should == :abc
  end
  
  it "builds any dependencies which are provided in constructor args" do
    returns_7 = RailsIOC::Prototype.new(String, ["7"])
    instance = RailsIOC::DependencyConstructor.new(ConstructorTestClass, []).construct([returns_7, :abc])
    instance.foo.should == "7"
    instance.bar.should == :abc
  end
  
  it "sets the provided backtrace in the event of an ArgumentError" do
    constructor = RailsIOC::DependencyConstructor.new(ConstructorTestClass, ["my_backtrace"])

    -> { constructor.construct([]) }.should raise_error(ArgumentError) do |e|
      e.backtrace.should == ["my_backtrace"]
    end
    
    -> { constructor.construct(nil) }.should raise_error do |e|
      e.backtrace.should_not == ["my_backtrace"]
    end
  end
end