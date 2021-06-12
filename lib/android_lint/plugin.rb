module Danger

  # Lint files of a gradle based Android project.
  # This is done using the Android's [Lint](https://developer.android.com/studio/write/lint.html) tool.
  # Results are passed out as tables in markdown.
  #
  # @example Running AndroidLint with its basic configuration
  #
  #          android_lint.lint
  #
  # @example Running AndroidLint with a specific gradle task
  #
  #          android_lint.gradle_task = "lintMyFlavorDebug"
  #          android_lint.lint
  #
  # @example Running AndroidLint without running a Gradle task
  #
  #          android_lint.skip_gradle_task = true
  #          android_lint.lint
  #
  # @example Running AndroidLint for a specific severity level and up
  #
  #          # options are ["Warning", "Error", "Fatal"]
  #          android_lint.severity = "Error"
  #          android_lint.lint
  #
  # @see loadsmart/danger-android_lint
  # @tags android, lint
  #
  class DangerAndroidLint < Plugin

    SEVERITY_LEVELS = ["Warning", "Error", "Fatal"]

    # Location of lint report file
    # If your Android lint task outputs to a different location, you can specify it here.
    # Defaults to "app/build/reports/lint/lint-result.xml".
    # @return [String]
    attr_accessor :report_file

    # A getter for `report_file`.
    # @return [String]
    def report_file
      return @report_file || 'app/build/reports/lint/lint-result.xml'
    end

    # Custom gradle task to run.
    # This is useful when your project has different flavors.
    # Defaults to "lint".
    # @return [String]
    attr_accessor :gradle_task

    # A getter for `gradle_task`, returning "lint" if value is nil.
    # @return [String]
    def gradle_task
      @gradle_task ||= "lint"
    end

    # Skip Gradle task.
    # This is useful when Gradle task has been already executed.
    # Defaults to `false`.
    # @return [Bool]
    attr_writer :skip_gradle_task

    # A getter for `skip_gradle_task`, returning `false` if value is nil.
    # @return [Boolean]
    def skip_gradle_task
      @skip_gradle_task ||= false
    end

    # Defines the severity level of the execution.
    # Selected levels are the chosen one and up.
    # Possible values are "Warning", "Error" or "Fatal".
    # Defaults to "Warning".
    # @return [String]
    attr_writer :severity

    # A getter for `severity`, returning "Warning" if value is nil.
    # @return [String]
    def severity
      @severity || SEVERITY_LEVELS.first
    end

    # Enable filtering
    # Only show messages within changed files.
    attr_accessor :filtering

    # Only shows messages for the modified lines.
    attr_accessor :filtering_lines

    # Calls lint task of your gradle project.
    # It fails if `gradlew` cannot be found inside current directory.
    # It fails if `severity` level is not a valid option.
    # It fails if `xmlReport` configuration is not set to `true` in your `build.gradle` file.
    # @return [void]
    #
    def lint(inline_mode: false)
      unless skip_gradle_task
        return fail("Could not find `gradlew` inside current directory") unless gradlew_exists?
      end

      unless SEVERITY_LEVELS.include?(severity)
        fail("'#{severity}' is not a valid value for `severity` parameter.")
        return
      end

      unless skip_gradle_task
        system "./gradlew #{gradle_task}"
      end

      unless File.exists?(report_file)
        fail("Lint report not found at `#{report_file}`. "\
          "Have you forgot to add `xmlReport true` to your `build.gradle` file?")
      end

      issues = read_issues_from_report
      filtered_issues = filter_issues_by_severity(issues)

      message = ""

      if inline_mode
        # Report with inline comment
        send_inline_comment(filtered_issues)
      else
        message = message_for_issues(filtered_issues)
        markdown("### AndroidLint found issues\n\n" + message) unless message.to_s.empty?
      end

      message
    end

    private

    def read_issues_from_report
      file = File.open(report_file)

      require 'oga'
      report = Oga.parse_xml(file)

      report.xpath('//issue')
    end

    def filter_issues_by_severity(issues)
      issues.select do |issue|
        severity_index(issue.get("severity")) >= severity_index(severity)
      end
    end

    def severity_index(severity)
      SEVERITY_LEVELS.index(severity) || 0
    end

    def message_for_issues(issues)
      message = ""

      SEVERITY_LEVELS.reverse.each do |level|
        filtered = issues.select{|issue| issue.get("severity") == level}
        message << parse_results(filtered, level) unless filtered.empty?
      end

      message
    end

    def parse_results(results, heading)
      target_files = (git.modified_files - git.deleted_files) + git.added_files
      dir = "#{Dir.pwd}/"
      count = 0;
      message = ""

      results.each do |r|
        location = r.xpath('location').first
        filename = location.get('file').gsub(dir, "")
        next unless !filtering || (target_files.include? filename)
        line = location.get('line') || 'N/A'
        reason = r.get('message')
        count = count + 1
        message << "`#{filename}` | #{line} | #{reason} \n"
      end
      if count != 0
        header = "#### #{heading} (#{count})\n\n"
        header << "| File | Line | Reason |\n"
        header << "| ---- | ---- | ------ |\n"
        message = header + message
      end

      message
    end


    # Send inline comment with danger's warn or fail method
    #
    # @return [void]
    def send_inline_comment (issues)
      target_files = (git.modified_files - git.deleted_files) + git.added_files
      dir = "#{Dir.pwd}/"
      SEVERITY_LEVELS.reverse.each do |level|
        filtered = issues.select{|issue| issue.get("severity") == level}
        next if filtered.empty?
        filtered.each do |r|
          location = r.xpath('location').first
          filename = location.get('file').gsub(dir, "")
          next unless !filtering || (target_files.include? filename)
          line = (location.get('line') || "0").to_i
          if filtering_lines
            added_lines = parseDiff(git.diff[filename].patch)
            next unless added_lines.include? line
          end
          send(level === "Warning" ? "warn" : "fail", r.get('message'), file: filename, line: line)
        end
      end
    end

    # parses git diff of a file and retuns an array of added line numbers.
    def parseDiff(diff)
      current_line_number = nil
      added_lines = []
      diff_lines = diff.strip.split("\n")
      diff_lines.each_with_index do |line, index|
        if m = /\+(\d+)(?:,\d+)? @@/.match(line)
          # (e.g. @@ -32,10 +32,7 @@)
          current_line_number = Integer(m[1])
        else
          if !current_line_number.nil?
            if line.start_with?('+')
              # added line
              added_lines.push current_line_number
              current_line_number += 1
            elsif !line.start_with?('-')
              # unmodified line
              current_line_number += 1
            end
          end
        end
      end
      added_lines
    end

    def gradlew_exists?
      `ls gradlew`.strip.empty? == false
    end
  end
end
