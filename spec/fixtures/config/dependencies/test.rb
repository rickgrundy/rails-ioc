RailsIOC::Dependencies.define do
  singleton :env_string, "Test"
  singleton :foo_string, "Foo"
  singleton :test_only_string, "This comes from test.rb"
end