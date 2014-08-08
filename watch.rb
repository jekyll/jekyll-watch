require 'pathname'

source = Pathname.new File.expand_path('spec/test-site')
opts = {
  'source' => source.to_s,
  'config' => [
    source.join('_config.yml').to_s,
    source.join('_config.dev.toml').to_s
  ],
  'serving' => true
}

require 'jekyll'
require File.expand_path('lib/jekyll-watch', __dir__)

Jekyll::Watcher.watch(Jekyll.configuration(opts))
Jekyll::Commands::Serve.process(opts)
