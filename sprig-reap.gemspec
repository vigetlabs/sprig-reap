$:.push File.expand_path("../lib", __FILE__)

require 'sprig/reap/version'

Gem::Specification.new do |spec|
  spec.name          = "sprig-reap"
  spec.version       = Sprig::Reap::VERSION
  spec.authors       = ["Ryan Stenberg"]
  spec.email         = ["ryan.stenberg@viget.com"]
  spec.homepage      = "http://www.github.com/vigetlabs/sprig-reap"
  spec.summary       = "Automatic seed file generation for Rails apps using Sprig."
  spec.description   = "Sprig-Reap is a gem that allows you to output your application's data state to seed files."
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  spec.test_files    = Dir["spec/**/*"]

  spec.add_development_dependency "rails",            "~> 3.1"
  spec.add_development_dependency "sqlite3",          "~> 1.3.8"
  spec.add_development_dependency "rspec",            "~> 2.14.0"
  spec.add_development_dependency "database_cleaner", "~> 1.2.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "generator_spec"
end
