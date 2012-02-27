# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "watchmouse/version"

Gem::Specification.new do |s|
  s.name        = "watchmouse"
  s.version     = Watchmouse::VERSION
  s.authors     = ["Pete Fritchman"]
  s.email       = ["petef@databits.net"]
  s.homepage    = "https://github.com/fetep/ruby-watchmouse"
  s.summary     = %q{Watchmouse API client}

  s.rubyforge_project = "watchmouse"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "json"
  s.add_runtime_dependency "rest-client"
  s.add_runtime_dependency "trollop"
end
