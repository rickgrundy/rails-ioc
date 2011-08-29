require File.expand_path("../../spec_helper.rb", __FILE__)

describe RailsIOC::Dependencies do
  class TestListNode
    attr_reader :next_node
    def initialize(next_node=nil)
      @next_node = next_node
    end
  end
  
  class TestController
    attr_reader :foo, :bar
  end
  
  describe "singletons" do
    it "creates and references singletons from a class and constructor args" do
      RailsIOC::Dependencies.define do
        singleton :second_node, TestListNode
        singleton :first_node, TestListNode, ref(:second_node)
      end
    
      first_node = RailsIOC::Dependencies.ref(:first_node)
      first_node.should be_a TestListNode
      first_node.should === RailsIOC::Dependencies.ref(:first_node)
      first_node.next_node.should === RailsIOC::Dependencies.ref(:second_node)
    end
    
    it "creates unreferenced singletons from a class and constructor args" do
      RailsIOC::Dependencies.define do
        singleton :first_node, TestListNode, singleton(TestListNode)
      end

      first_node = RailsIOC::Dependencies.ref(:first_node)
      first_node.should be_a(TestListNode)
      first_node.next_node.should be_a TestListNode
    end
    
    it "does not require a class for simple types" do
      RailsIOC::Dependencies.define do
        singleton :a_number, 12345
      end
      
      RailsIOC::Dependencies.ref(:a_number).should == 12345
    end
    
    it "raises an error containing information about original definition if the wrong number of constructor args are defined" do
      defining_line = __LINE__ + 3
      -> {
        RailsIOC::Dependencies.define do
          singleton :a_string, String, "Too", "many", "args"
        end
      }.should raise_error(ArgumentError) { |e|
        e.backtrace.find { |l| l =~ /dependencies_spec.rb:#{defining_line}/ }.should_not be_nil
      }
    end
  end
  
  describe "prototypes" do
    it "creates and references prototypes from a class and constructor args" do
      RailsIOC::Dependencies.define do
        prototype :second_node, TestListNode
        prototype :first_node, TestListNode, ref(:second_node)
      end
    
      ref = RailsIOC::Dependencies.ref(:first_node)
      ref.should be_a Proc
      first_node = ref.call
      first_node.should be_a TestListNode
      first_node.should_not === ref.call 
      
      first_node.next_node.should be_a TestListNode
      first_node.next_node.should_not === RailsIOC::Dependencies.ref(:second_node).call
    end
    
    it "creates unreferenced prototypes from a class and constructor args" do
      RailsIOC::Dependencies.define do
        prototype :first_node, TestListNode, prototype(TestListNode)
      end

      ref = RailsIOC::Dependencies.ref(:first_node)
      ref.should be_a Proc
      first_node = ref.call
      first_node.should be_a(TestListNode)
      first_node.next_node.should be_a TestListNode
    end
    
    it "raises an error containing information about original definition if the wrong number of constructor args are defined" do
      defining_line = __LINE__ + 2
      RailsIOC::Dependencies.define do
        prototype :a_string, String, "Too", "many", "args"
      end
            
      -> { RailsIOC::Dependencies.ref(:a_string).call }.should raise_error(ArgumentError) { |e|
        e.backtrace.find { |l| l =~ /dependencies_spec.rb:#{defining_line}/ }.should_not be_nil
      }
    end
  end
  
  describe "controllers" do
    it "stores controller dependencies for later injection by Rails' before_filter" do      
      RailsIOC::Dependencies.define do
        prototype :second_node, TestListNode
        singleton :first_node, TestListNode, ref(:second_node)
        
        controller TestController, {
           foo: ref(:first_node),
           bar: singleton("The Sheep Says Bar")
        }
      end
      
      controller = TestController.new
      dependencies = RailsIOC::Dependencies.controllers[TestController]
      RailsIOC::DependencyInjector.new(controller).inject(dependencies)
      
      controller.foo.should === RailsIOC::Dependencies.ref(:first_node)
      controller.bar.should == "The Sheep Says Bar"
    end
  end
  
  describe "loading dependencies file" do
    before(:each) do
      GlobalCounter.zero!
    end
    
    it "reloads the file if cache_classes is false" do
      Rails.env = "incrementing_test"
      Rails.application.config.cache_classes = false
      
      RailsIOC::Dependencies.load!
      RailsIOC::Dependencies.ref(:counter).should == 1
      
      RailsIOC::Dependencies.load!
      RailsIOC::Dependencies.ref(:counter).should == 2
    end
    
    it "does not reload the file if cache_classes is true" do
      Rails.env = "incrementing_test"
      Rails.application.config.cache_classes = true

      RailsIOC::Dependencies.load!
      RailsIOC::Dependencies.ref(:counter).should == 1
      
      RailsIOC::Dependencies.load!
      RailsIOC::Dependencies.ref(:counter).should == 1
    end
  end
  
  describe "inheriting environments" do
    it "loads the corresponding dependencies file" do
      RailsIOC::Dependencies.inherit_environment("production")
      RailsIOC::Dependencies.ref(:env_string).should == "Production"
      RailsIOC::Dependencies.ref(:foo_string).should == "Foo"
      RailsIOC::Dependencies.ref(:production_only_string).should == "This comes from production.rb"
      -> { RailsIOC::Dependencies.ref(:test_only_string) }.should raise_error RailsIOC::MissingReferenceError
      
      RailsIOC::Dependencies.inherit_environment("test")
      RailsIOC::Dependencies.ref(:env_string).should == "Test"
      RailsIOC::Dependencies.ref(:foo_string).should == "Foo"
      RailsIOC::Dependencies.ref(:production_only_string).should == "This comes from production.rb"
      RailsIOC::Dependencies.ref(:test_only_string).should == "This comes from test.rb"
    end
  end
end