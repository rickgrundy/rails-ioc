require "rails-ioc/version"
require "rails-ioc/errors"
require "rails-ioc/dependencies"
require "rails-ioc/dependency_constructor"
require "rails-ioc/dependency_injector"
require "rails-ioc/singleton"
require "rails-ioc/prototype"
require "rails-ioc/reference"
      
raise RailsIOC::NoRailsError.new(:Rails) unless defined?(Rails)
raise RailsIOC::NoRailsError.new(:ActionController) unless defined?(ActionController)
require "rails-ioc/controller_extension"
ActionController::Base.send(:include, RailsIOC::ControllerExtension)

if defined?(RSpec)
  require "rails-ioc/rspec_extension"
  Object.send(:include, RailsIOC::RSpecExtension)
end