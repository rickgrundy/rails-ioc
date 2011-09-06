require File.expand_path("../../spec_helper.rb", __FILE__)

describe RailsIOC::DependencyInjector do
  class InjectorTestClass
    attr_reader :foo, :bar
  end
  
  it "injects named variables for the given class" do
    instance = RailsIOC::DependencyInjector.new(InjectorTestClass.new).inject(foo: 123, bar: :abc)
    instance.foo.should == 123
    instance.bar.should == :abc
  end
  
  it "calls any procs which are provided in constructor args" do
    returns_7 = RailsIOC::Prototype.new(String, ["7"])
    instance = RailsIOC::DependencyInjector.new(InjectorTestClass.new).inject(foo: returns_7, bar: :abc)
    instance.foo.should == "7"
    instance.bar.should == :abc
  end
end