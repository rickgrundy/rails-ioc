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
end