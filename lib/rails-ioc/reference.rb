module RailsIOC
  class Reference
    def initialize(name, defined_dependencies)
      @name = name
      @defined_dependencies = defined_dependencies
    end
    
    def build
      dependency = @defined_dependencies[@name]
      raise MissingReferenceError.new(@name) if dependency.nil?
      if dependency.respond_to?(:build)
        dependency.build
      else
        dependency
      end
    end
  end
end