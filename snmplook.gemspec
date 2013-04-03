# -*- encoding: utf-8 -*-
require File.expand_path('../lib/snmplook/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Martin Gabler"]
  gem.email         = ["martin.gabler@yahoo.de"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "snmplook"
  gem.require_paths = ["lib"]
  gem.version       = Snmplook::VERSION
  gem.add_development_dependency('rdoc')
  gem.add_development_dependency('aruba')
  gem.add_development_dependency('rake', '~> 0.9.2')
  gem.add_dependency('methadone', '~> 1.2.6')
end
