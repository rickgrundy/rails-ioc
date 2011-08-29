module RailsIOC
  module RSpecExtension
    def self.included(klass)
      RSpec.configure do |config|
        config.before(:each) { RailsIOC::Dependencies.reset! }
      end
    end
    
    def controller_dependencies(dependencies)
      klass = controller.class
      Dependencies.define do
        controller klass, dependencies
      end
      dependencies.keys.each { |field| controller.class.send(:attr_reader, field) }
    end
  end
end