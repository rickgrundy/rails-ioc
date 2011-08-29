require File.expand_path("../../spec_helper.rb", __FILE__)

describe RailsIOC::RSpecExtension do
  class MyController; end
  def controller; MyController.new; end
  
  describe "resetting dependencies between tests" do
    after(:each) do
      RailsIOC::Dependencies.define { singleton :defined?, true }
    end
    
    it "resets before this test" do
      -> { RailsIOC::Dependencies.ref(:defined?) }.should raise_error RailsIOC::MissingReferenceError
    end
    
    it "also resets before this test" do
      -> { RailsIOC::Dependencies.ref(:defined?) }.should raise_error RailsIOC::MissingReferenceError
    end
  end
  
  it "provides a shorthand way to define controller dependencies" do
    controller_dependencies(who_am_i: "The Walrus")
    RailsIOC::Dependencies.controllers[MyController][:who_am_i].should == "The Walrus"
  end
end