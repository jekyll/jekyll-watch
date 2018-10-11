# Jekyll Watch

Rebuild your Jekyll site when a file changes with the `--watch` switch.

[![Linux Build Status](https://img.shields.io/travis/jekyll/jekyll-watch/master.svg?label=Linux%20build)][travis]
[![Windows Build status](https://img.shields.io/appveyor/ci/jekyll/jekyll-watch/master.svg?label=Windows%20build)][appveyor]

[travis]: https://travis-ci.org/jekyll/jekyll-watch
[appveyor]: https://ci.appveyor.com/project/jekyll/jekyll-watch

## Installation

**`jekyll-watch` comes pre-installed with Jekyll 2.1 or greater.**

Add this line to your application's Gemfile:

    gem 'jekyll-watch'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jekyll-watch

## Usage

Pass the `--watch` flag to `jekyll build` or `jekyll serve`:

```bash
$ jekyll build --watch
$ jekyll serve --watch # this flag is the default, so no need to specify it here for the 'serve' command
```

The `--watch` flag can be used in combination with any other flags for those
two commands, except `--detach` for the `serve` command.

## Contributing

1. Fork it ( https://github.com/jekyll/jekyll-watch/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
