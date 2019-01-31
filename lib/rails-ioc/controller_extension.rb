module RailsIOC
  module ControllerExtension
    def self.included(controller)
      controller.before_action :inject_dependencies
    end
    
    def inject_dependencies
      RailsIOC::Dependencies.load!
      dependencies = RailsIOC::Dependencies.controllers[self.class] || {}      
      RailsIOC::DependencyInjector.new(self).inject(dependencies)
    end
  end
end