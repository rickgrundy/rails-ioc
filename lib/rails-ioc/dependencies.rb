module RailsIOC
  class Dependencies    
    def self.reset!
      @dependencies = {}
      @controllers = {}
      @loaded = false 
    end
    self.reset!
    
    def self.load!
      self.reset! unless Rails.application.config.cache_classes
      if !@loaded
        inherit_environment(Rails.env)
        @loaded = true
      end
    end
    
    def self.define(&definition)
      class_exec(&definition)
    end
  
    def self.inherit_environment(env)
      load File.join(Rails.root, "config", "dependencies", "#{env}.rb")
    end
  
    def self.controller(klass, dependencies)
      @controllers[klass] ||= {}
      @controllers[klass].merge!(dependencies)
    end
  
    def self.singleton(*args)
      store_dependency(args) do |klass, constructor_args|
        if klass.instance_of?(Class)
          DependencyConstructor.new(klass, caller).construct(constructor_args)
        else
          klass
        end
      end
    end
  
    def self.prototype(*args)
      store_dependency(args) do |klass, constructor_args|
        definition_backtrace = caller
        -> { DependencyConstructor.new(klass, definition_backtrace).construct(constructor_args) }
      end
    end
  
    def self.ref(name)
      @dependencies[name] || raise(MissingReferenceError.new(name))
    end
    
    def self.controllers
      @controllers
    end
  
    private
    
    def self.store_dependency(args)
      if args.first.is_a?(Symbol)
        @dependencies[args.shift] = yield(args.shift, args)
      else
        yield(args.shift, args)
      end
    end
  end
end