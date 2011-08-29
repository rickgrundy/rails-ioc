require File.expand_path("../spec_helper.rb", __FILE__)

describe "Spec Helper" do
  it "provides a global counter" do
    3.times { GlobalCounter.increment! }
    GlobalCounter.count.should == 3
    GlobalCounter.zero!
    GlobalCounter.count.should == 0
  end
  
  describe "zeroing the global counter between tests" do
    after(:each) { GlobalCounter.increment! }
    
    it "zeroes before this test" do
      GlobalCounter.count.should == 0
    end
    
    it "also zeroes before this test" do
      GlobalCounter.count.should == 0
    end
  end
  
  it "simulates Rails.application.config to allow testing outside a Rails app" do
    Rails.application.config.kittens = "Small Cats"
    Rails.application.config.kittens.should == "Small Cats"
  end
  
  describe "resetting fake Rails environment between tests" do
    after(:each) do
      ignoring_warnings do
        Rails = nil
        ActionController = nil
      end
    end
    
    it "resets Rails before this test" do
      ActionController.should_not be_nil
      Rails.application.should_not be_nil
    end    
    
    it "resets Rails before this test too" do
      ActionController.should_not be_nil
      Rails.application.should_not be_nil
    end
  end
end