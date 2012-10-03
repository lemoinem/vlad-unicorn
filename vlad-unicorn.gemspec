# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vlad-unicorn/version'

Gem::Specification.new do |gem|
  gem.name          = "vlad-unicorn"
  gem.version       = Vlad::Unicorn::VERSION
  gem.authors       = ["Kevin R. Bullock"]
  gem.email         = ["kbullock@ringworld.org"]
  gem.description   = %q{Unicorn app server support for Vlad. Adds support for vlad:start_app and vlad:stop_app using Unicorn[http://unicorn.bogomips.org/].}
  gem.summary       = %q{Unicorn app server support for Vlad.}
  gem.homepage      = "https://bitbucket.org/krbullock/vlad-unicorn"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"] + gem.files.grep(%r{^docs/})

  gem.add_runtime_dependency "vlad", ["~> 2.3"]
end
