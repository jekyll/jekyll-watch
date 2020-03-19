# frozen_string_literal: true

require_relative "lib/jekyll-watch/version"

Gem::Specification.new do |spec|
  spec.name          = "jekyll-watch"
  spec.version       = Jekyll::Watch::VERSION
  spec.authors       = ["Parker Moore"]
  spec.email         = ["parkrmoore@gmail.com"]
  spec.summary       = "Rebuild your Jekyll site when a file changes with the `--watch` switch."
  spec.homepage      = "https://github.com/jekyll/jekyll-watch"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").grep(%r!(bin|lib)/!)
  spec.executables   = spec.files.grep(%r!^bin/!) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.3.0"

  spec.add_runtime_dependency "listen", "~> 3.0"

  require "rbconfig"
  if RbConfig::CONFIG["host_os"] =~ %r!mswin|mingw|cygwin!
    spec.add_runtime_dependency "wdm", "~> 0.1.0"
  end

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "jekyll", ">= 3.6", "< 5.0"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop-jekyll", "~> 0.11"
end
