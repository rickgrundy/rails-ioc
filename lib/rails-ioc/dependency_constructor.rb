module RailsIOC
  class DependencyConstructor
    def initialize(klass, definition_backtrace)
      @klass = klass
      @definition_backtrace = definition_backtrace
    end
    
    def construct(dependencies)
      begin
        @klass.new(*dependencies.map { |dependency| call_lazy_initializers(dependency) })
      rescue ArgumentError => e
        e.set_backtrace(@definition_backtrace)
        raise e
      end
    end
    
    private
    
    def call_lazy_initializers(dependency)
      if dependency.respond_to?(:build)
        call_lazy_initializers(dependency.build)
      else
        dependency
      end
    end
  end
end