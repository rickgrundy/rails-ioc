require File.expand_path("../../spec_helper.rb", __FILE__)

describe RailsIOC::ControllerExtension do  
  it "injects pre-defined dependencies" do        
    Rails.application.config.cache_classes = true
    RailsIOC::Dependencies.instance_variable_set :@loaded, true
    
    RailsIOC::Dependencies.define do
      controller ExtendedController, {
        a_number: 123,
        a_string: "Hello" 
      }
    end
    
    controller = ExtendedController.new    
    controller.trigger_before_action!
    controller.instance_variable_get(:@a_number).should == 123
    controller.instance_variable_get(:@a_string).should == "Hello"
  end
end