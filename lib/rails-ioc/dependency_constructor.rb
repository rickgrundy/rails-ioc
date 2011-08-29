module RailsIOC
  class DependencyConstructor
    def initialize(klass, definition_backtrace)
      @klass = klass
      @definition_backtrace = definition_backtrace
    end
    
    def construct(dependencies)
      begin
        @klass.new(*dependencies.map { |x| x.is_a?(Proc) ? x.call : x })
      rescue ArgumentError => e
        e.set_backtrace(@definition_backtrace)
        raise e
      end
    end
  end
end