require 'oga'

module Danger

  class DangerAndroidLint < Plugin

    SEVERITY_LEVELS = ["Warning", "Error", "Fatal"]

    attr_accessor :gradle_task

    attr_accessor :severity

    def lint
      unless gradlew_exists?
        fail("Could not find `gradlew` inside current directory")
        return
      end

      unless SEVERITY_LEVELS.include?(severity)
        fail("'#{severity}' is not a valid value for `severity` parameter.")
        return
      end

      unless File.exists?("app/build/reports/lint/lint-result.xml")
        fail("Lint report not found at `app/build/reports/lint/lint-result.xml`. "\
          "Have you forgot to add `xmlReport true` to your `build.gradle` file?")
      end

      system "./gradlew #{gradle_task || 'lint'}"

      issues = read_issues_from_report
      message = message_for_issues(issues)
      markdown(message) unless issues.empty?
    end

    private

    def read_issues_from_report()
      file = File.open("app/build/reports/lint/lint-result.xml")
      report = Oga.parse_xml(file)
      report.xpath('//issue')
    end

    def message_for_issues(issues)
      message = "### AndroidLint found issues\n\n"

      severity_index = SEVERITY_LEVELS.index(severity) || 0
      levels = SEVERITY_LEVELS.slice(severity_index, SEVERITY_LEVELS.size)
      levels.reverse.each do |level|
        filtered = issues.select{|issue| issue.get("severity") == level}
        message << parse_results(filtered, level) unless filtered.empty?
      end

      message
    end

    def parse_results(results, heading)
      message = "#### #{heading} (#{results.count})\n\n"

      message << "| File | Line | Reason |\n"
      message << "| ---- | ---- | ------ |\n"

      results.each do |r|
        location = r.xpath('location').first
        filename = location.get('file').split('/').last
        line = location.get('line') || 'N/A'
        reason = r.get('message')

        message << "`#{filename}` | #{line} | #{reason} \n"
      end

      message
    end

    def gradlew_exists?
      `ls gradlew`.strip.empty? == false
    end
  end
end
