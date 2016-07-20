# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "jekyll-watch"
  spec.version       = "1.5.0"
  spec.authors       = ["Parker Moore"]
  spec.email         = ["parkrmoore@gmail.com"]
  spec.summary       = %q{Rebuild your Jekyll site when a file changes with the `--watch` switch.}
  spec.homepage      = "https://github.com/jekyll/jekyll-watch"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").grep(%r{(bin|lib)/})
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # XXX: Remove the lock with Jekyll 4 or in 2017 when Ruby 2.1 goes EOL.
  spec.add_runtime_dependency "listen", "~> 3.0", "< 3.1"

  require 'rbconfig'
  if RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
    spec.add_runtime_dependency "wdm", "~> 0.1.0"
  end

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rubocop", "~> 0.35.1"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "jekyll", ENV["JEKYLL_VERSION"] ? "~> #{ENV["JEKYLL_VERSION"]}" : ">= 2.0"
end
