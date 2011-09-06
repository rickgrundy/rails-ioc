module RailsIOC
  class Prototype
    def initialize(klass, constructor_args)
      @klass = klass
      @constructor_args = constructor_args
      @defining_stacktrace = caller
    end
    
    def build
      DependencyConstructor.new(@klass, @defining_stacktrace).construct(@constructor_args)
    end
  end
end