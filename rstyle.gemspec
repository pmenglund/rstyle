# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rstyle/version"

Gem::Specification.new do |s|
  s.name        = "rstyle"
  s.version     = Rstyle::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Martin Englund"]
  s.email       = ["martin@englund.nu"]
  s.homepage    = "https://github.com/pmenglund/rstyle"
  s.summary     = %q{Style checking for Ruby code}
  s.description = %q{Style checking for Ruby code}

  s.rubyforge_project = "rstyle"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "highline"
  s.add_runtime_dependency "trollop"

  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"
end
