RailsIOC::Dependencies.define do
  singleton :env_string, "Production"
  singleton :foo_string, "Foo"
  singleton :production_only_string, "This comes from production.rb"
end