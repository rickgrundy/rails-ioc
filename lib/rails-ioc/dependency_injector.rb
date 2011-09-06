module RailsIOC
  class DependencyInjector
    def initialize(target)
      @target = target
    end
    
    def inject(dependencies)
      dependencies.each do |field, dependency|
        @target.instance_variable_set("@#{field}", call_lazy_initializers(dependency))
      end
      @target
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