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

#### Skip gradle task execution

If you want to skip the gradle task execution. You can achieve that by simply changing the value of `skip_gradle_task`. Default is `false`.

```rb
android_lint.skip_gradle_task = true
android_lint.lint
```

#### Changing report's file path

If you're using a path to output your report file other than the default one, you can specify it by setting a new value to `report_file`:

```rb
android_lint.report_file = "your/report/file.xml"
android_lint.lint
```

#### Changing report's severity level

If you want to filter lint issues based on their severity level, you can do that by setting a value to `severity`. Bear in mind that you are filtering issues by the severity level you've set **and up**. Possible values are `Warning`, `Error` and `Fatal`. Default is `Warning` (which is everything).

```rb
android_lint.severity = "Error"
android_lint.lint
```

#### Lint only added/modified files

If you're dealing with a legacy project, with tons of warnings, you may want to lint only new/modified files. You can easily achieve that, setting the `filtering` parameter to `true`.

```rb
android_lint.filtering = true
android_lint.lint
```

Additionally, you can further filter to only the modified lines by setting the `filtering_lines` parameter to `true`.

```rb
android_lint.filtering_lines = true
android_lint.lint
```

#### Filter issues by ID

In some cases you may want to conditionally ignore specific lint warnings without fully disabling
them in your `lintOptions` configuration. To do that, you can pass a list of IDs to the
`filter_issue_ids` parameter.

```rb
android_lint.filter_issue_ids = ["MissingTranslation"]
android_lint.lint
```

#### Make Danger comment directly on the line instead of printing a Markdown table (GitHub only)

```rb
android_lint.lint(inline_mode: true)
```

## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Run `bundle exec rake spec` to run the tests.
4. Use `bundle exec guard` to automatically have tests run as you make changes.
5. Make your changes.

## License

[MIT](https://raw.githubusercontent.com/loadsmart/danger-android_lint/master/LICENSE.txt)
