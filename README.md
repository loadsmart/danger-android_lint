[![CircleCI](https://circleci.com/gh/loadsmart/danger-android_lint.svg?style=svg)](https://circleci.com/gh/loadsmart/danger-android_lint)

# danger-android_lint

Lint files of a gradle based Android project.

## Installation

### Via global gems

```
$ gem install danger-android_lint
```

### Via Bundler

Add the following line to your Gemfile and then run `bundle install`:

```rb
gem 'danger-android_lint'
```

## Usage

Before all, you need to turn lint reports on in your `build.gradle` file. You can do this by adding the `xmlReport true` option, like:

```gradle
android {
    lintOptions {
        xmlReport true
    }
}
```

### Basic

```rb
android_lint.lint
```

### Advanced

#### Using a custom gradle task

In case you have multiple flavors, you may want to change the gradle task that runs the lint command. You can achieve that by simply changing the value of `gradle_task`. Default is `lint`.

```rb
android_lint.gradle_task = "lintMyFlavorDebug"
android_lint.lint
```

#### Changing report's severity level

If you want to filter lint issues based on their severity level, you can do that by setting a value to `severity`. Bear in mind that you are filtering issues by the severity level you've set **and up**. Possible values are `Warning`, `Error` and `Fatal`. Default is `Warning` (which is everything).

```rb
android_lint.severity = "Error"
android_lint.lint
```

## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Run `bundle exec rake spec` to run the tests.
4. Use `bundle exec guard` to automatically have tests run as you make changes.
5. Make your changes.

## License

MIT

## TODO
- [x] add `gradle_task` as a `attr_accessor` (defaults to `lint`)
- [x] add `severity` as a `attr_accessor` (defaults to `Warning`)
- [x] write specs
- [x] add code comments
- [x] create a changelog
- [x] configure ci build
- [x] fill out readme.md
- [x] open source it
- [ ] publish gem
- [ ] send MR to danger.systems
