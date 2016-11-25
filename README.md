⚠️ Note: This plugin is still under heavy development 👷

[![CircleCI](https://circleci.com/gh/loadsmart/danger-android_lint.svg?style=svg)](https://circleci.com/gh/loadsmart/danger-android_lint)

# danger-android_lint

A description of danger-android_lint.

## Installation

    $ gem install danger-android_lint

## Usage

## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Run `bundle exec rake spec` to run the tests.
4. Use `bundle exec guard` to automatically have tests run as you make changes.
5. Make your changes.

## TODO
- [x] add `gradle_task` as a `attr_accessor` (defaults to `lint`)
- [x] add `severity` as a `attr_accessor` (defaults to `Warning`)
- [x] write specs
- [ ] add code comments
- [ ] add link to bot's comment pointing to html report artifact
- [ ] fill out readme.md
- [x] create a changelog
- [ ] open souce it
- [ ] publish gem
- [ ] create its own Dangerfile
- [x] configure ci build
- [ ] send MR to danger.systems
