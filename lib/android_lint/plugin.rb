require 'oga'

module Danger

  class DangerAndroidLint < Plugin

    def lint_files
      system "./gradlew lintStagingDebug"
      file = File.open("android-lint-report.xml")
      report = Oga.parse_xml(file)
      issues = report.xpath('//issue')

      warnings = issues.select{|issue| issue.get("severity") == "Warning"}
      errors = issues.select{|issue| issue.get("severity") == "Error"}

      message = ''
      if warnings.count > 0 || errors.count > 0
        message = "### AndroidLint found issues\n\n"
      end

      message << parse_results(warnings, 'Warnings') unless warnings.empty?
      message << parse_results(errors, 'Errors') unless errors.empty?

      markdown message unless message.empty?
    end

    def parse_results(results, heading)
      message = "#### #{heading}\n\n"

      message << "| File | Line | Reason |\n"
      message << "| ---- | ---- | ------ |\n"

      results.each do |r|
        location = r.xpath('location').first
        filename = location.get('file').split('/').last
        line = location.get('line') || 'N/A'
        reason = r.get('message')

        message << "#{filename} | #{line} | #{reason} \n"
      end

      message
    end
  end
end
