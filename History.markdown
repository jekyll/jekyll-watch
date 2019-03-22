## 2.2.1 / 2019-03-22

### Bug Fixes

  * Fix encoding discrepancy in excluded Windows paths (#76)
  * Ignore directories rather than all similar paths (#65)

### Development Fixes

  * Test against Ruby 2.6
  * Relax version constraint on bundler to allow using 1.x or 2.x
  * dependencies: rubocop-jekyll 0.5
  * style: target Ruby 2.4

## 2.2.0 (YANKED)

## 2.1.2 / 2018-10-17

### Development Fixes

  * Initialize AppVeyor CI to test plugin on Windows (#77)

### Bug Fixes

  * Fix watcher failure due to incorrect file name encoding (#78)

## 2.1.1 / 2018-10-10

### Bug Fixes

  * Replace non-existent local variable (#73)

## 2.1.0 / 2018-10-09

### Bug Fixes

  * Normalize watched-path encoding (#69)

### Development Fixes

  * Test against Ruby 2.5 (#62)
  * Drop support for Ruby 2.2 (EOL)
  * Style: lint with rubocop-jekyll

## 2.0.0 / 2016-12-02

### Development Fixes

  * Update versions for Travis (#43)
  * Define path with __dir__ (#48)
  * Remove version lock for dependency listen (#50)
  * Inherit Jekyll&#39;s rubocop config for consistency (#51)
  * Update jekyll-watch (#53)
  * Drop support for old Ruby and old Jekyll (#55)

### Minor Enhancements

  * Output regenerated file paths to terminal (#57)

### Major Enhancements

  * Remove unnecessary method (#56)

## 1.5.0 / 2016-07-20

  * reuse provided site instance if available (#40)

## 1.4.0 / 2016-04-25

  * Lock Listen to less than 3.1. (#38)

## 1.3.1 / 2016-01-19

  * Test against Jekyll 2 and 3. (#30)
  * watcher: set `LISTEN_GEM_DEBUGGING` if `--verbose` flag set (#31)
  * Apply Rubocop auditing and fix up (#32)

## 1.3.0 / 2015-09-23

  * Lock to Listen 3.x (#25)

## 1.2.1 / 2015-01-24

  * Show regen time & use the same `Site` object across regens (#21)

## 1.2.0 / 2014-12-05

  * *Always* ignore `.jekyll-metadata`, even if it doesn't exist. (#18)
  * Ignore `.jekyll-metadata` by default if it exists (#15)

## 1.1.2 / 2014-11-08

  * Only ignore a file or directory if it exists (#13)

## 1.1.1 / 2014-09-05

  * Exclude test files from the gem build (#9)

## 1.1.0 / 2014-08-10

### Minor Enhancements

  * Refactor the whole watching thing and compartmentalize it. (#5)
  * Don't listen to things in the `exclude` configuration option. (#5)

### Development Fixes

  * Add github stuff and the beginnings of the test suite (#6)
  * Flesh out the test suite (#7)

## 1.0.0 / 2014-06-27

  * Birthday!
