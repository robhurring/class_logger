# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'class_logger'

Gem::Specification.new do |s|
  s.name        = "class_logger"
  s.version     = ClassLogger::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Rob Hurring"]
  s.email       = ["rob@ubrio.us"]
  s.homepage    = ""
  s.summary     = %q{Adds custom logger(s) to any ruby module or class}
  s.description = %q{Allows you to create multiple loggers for any given class}

  s.rubyforge_project = "class_logger"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
