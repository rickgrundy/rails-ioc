# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rails-ioc/version"

Gem::Specification.new do |s|
  s.name        = "rails-ioc"
  s.version     = RailsIOC::VERSION
  s.authors     = ["Rick Grundy"]
  s.email       = ["rick@rickgrundy.com"]
  s.homepage    = "http://www.github.com/rickgrundy/rails-ioc"
  s.summary     = "Simple dependency injection for Rails."
  s.description = "Simple dependency injection for Rails."

  s.rubyforge_project = "rails-ioc"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
  # specify any dependencies here; for example:
  # s.add_runtime_dependency "rest-client"
end
