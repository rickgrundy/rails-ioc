RailsIOC::Dependencies.define do
  singleton :env_string, "Production"
  singleton :foo_string, "Foo"
  singleton :production_only_string, "This comes from production.rb"
  
  controller ExtendedController, {
    env_string: ref(:env_string),
    production_only_string: ref(:production_only_string)
  }
end