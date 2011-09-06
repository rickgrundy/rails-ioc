require File.expand_path("../../spec_helper.rb", __FILE__)

describe RailsIOC::RSpecExtension do
  def controller
    @controller ||= ExtendedController.new
  end
  
  describe "resetting dependencies between tests" do
    after(:each) do
      RailsIOC::Dependencies.define { singleton :defined?, true }
    end
    
    it "resets before this test" do
      -> { RailsIOC::Dependencies.ref(:defined?).build }.should raise_error RailsIOC::MissingReferenceError
    end
    
    it "also resets before this test" do
      -> { RailsIOC::Dependencies.ref(:defined?).build }.should raise_error RailsIOC::MissingReferenceError
    end
  end
  
  it "provides a shorthand way to define and expose controller depend3encies" do    
    Rails.application.config.cache_classes = true
    RailsIOC::Dependencies.instance_variable_set :@loaded, true
    
    controller_dependencies(who_am_i: "The Walrus")
    controller.trigger_before_filter!
    controller.who_am_i.should == "The Walrus"
  end
end