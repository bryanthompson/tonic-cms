# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "tonic-cms/version"

Gem::Specification.new do |s|
  s.name        = "tonic-cms"
  s.version     = Tonic::Cms::VERSION
  s.authors     = ["Bryan Thompson"]
  s.email       = ["bryan@madebymarket.com"]
  s.homepage    = ""
  s.summary     = %q{client gem for the tonic cms}
  s.description = %q{client gem for the tonic cms}

  s.rubyforge_project = "tonic-cms"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
