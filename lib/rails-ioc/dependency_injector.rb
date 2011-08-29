module RailsIOC
  class DependencyInjector
    def initialize(target)
      @target = target
    end
    
    def inject(dependencies)
      dependencies.each do |field, value|
        value = value.call if value.is_a?(Proc)
        @target.instance_variable_set("@#{field}", value)
      end
      @target
    end
  end
end