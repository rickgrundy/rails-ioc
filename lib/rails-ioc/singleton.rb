module RailsIOC
  class Singleton
    def initialize(klass, constructor_args)
      @klass = klass
      @constructor_args = constructor_args
      @defining_stacktrace = caller
    end
    
    def build
      @instance ||= DependencyConstructor.new(@klass, @defining_stacktrace).construct(@constructor_args)
    end
  end
end