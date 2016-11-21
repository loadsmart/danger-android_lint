# danger-android_lint

A description of danger-android_lint.

## Installation

    $ gem install danger-android_lint

## Usage

    Methods and attributes from this plugin are available in
    your `Dangerfile` under the `android_lint` namespace.

## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Run `bundle exec rake spec` to run the tests.
4. Use `bundle exec guard` to automatically have tests run as you make changes.
5. Make your changes.

## TODO
- [ ] add `gradle_task` as a `attr_accessor` (defaults to `lint`)
- [ ] add `severity` as a `attr_accessor` (defaults to `Warning`)
- [ ] add `xml_report_file` as a `attr_accessor`
- [ ] write specs
- [ ] add code comments
- [ ] add link to bot's comment pointing to html report artifact
- [ ] fill out readme.md
- [ ] create a changelog
- [ ] open souce it
- [ ] send MR to danger.systems
