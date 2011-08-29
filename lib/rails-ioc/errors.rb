module RailsIOC
  class BaseError < StandardError; end
  class NoRailsError < BaseError
    def initialize(missing_class)
      super("#{missing_class} is not defined. RailsIOC can only be used within a Rails application.")
    end
  end
  
  class MissingReferenceError < BaseError
    def initialize(name)
      super("No dependency defined with name :#{name}.")
    end
  end
end