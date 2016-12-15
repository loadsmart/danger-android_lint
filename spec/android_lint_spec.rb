require File.expand_path('../spec_helper', __FILE__)

module Danger
  describe Danger::DangerAndroidLint do
    it 'should be a plugin' do
      expect(Danger::DangerAndroidLint.new(nil)).to be_a Danger::Plugin
    end

    describe 'with Dangerfile' do
      before do
        @dangerfile = testing_dangerfile
        @android_lint = @dangerfile.android_lint
      end

      it "Fails if gradlew does not exist" do
        allow(@android_lint).to receive(:`).with("ls gradlew").and_return("")

        @android_lint.lint
        expect(@android_lint.status_report[:errors]).to eq(["Could not find `gradlew` inside current directory"])
      end

      it "Fails if severity is an unknown value" do
        allow(@android_lint).to receive(:`).with("ls gradlew").and_return("gradlew")

        @android_lint.severity = "Dummy"
        @android_lint.lint

        expect(@android_lint.status_report[:errors]).to eq(["'Dummy' is not a valid value for `severity` parameter."])
      end

      it "Sets severity to 'Warning' if no severity param is provided" do
        allow(@android_lint).to receive(:`).with("ls gradlew").and_return("gradlew")
        allow(File).to receive(:exists?).with(Danger::DangerAndroidLint::REPORT_FILE).and_return(true)

        fake_result = File.open("spec/fixtures/lint-result-with-everything.xml")
        allow(File).to receive(:open).with(Danger::DangerAndroidLint::REPORT_FILE).and_return(fake_result)

        @android_lint.lint
        expect(@android_lint.severity).to eq("Warning")
      end

      it "Fails if report file does not exist" do
        allow(@android_lint).to receive(:`).with("ls gradlew").and_return("gradlew")
        allow(File).to receive(:exists?).with(Danger::DangerAndroidLint::REPORT_FILE).and_return(false)

        fake_result = File.open("spec/fixtures/lint-result-with-everything.xml")
        allow(File).to receive(:open).with(Danger::DangerAndroidLint::REPORT_FILE).and_return(fake_result)

        @android_lint.lint

        expect(@android_lint.status_report[:errors]).to eq(["Lint report not found at `app/build/reports/lint/lint-result.xml`. "\
          "Have you forgot to add `xmlReport true` to your `build.gradle` file?"])
      end

      describe 'lint' do
        before do
          allow(@android_lint).to receive(:`).with("ls gradlew").and_return("gradlew")
          allow(File).to receive(:exists?).with(Danger::DangerAndroidLint::REPORT_FILE).and_return(false)
        end

        it 'Prints markdown if issues were found' do
          fake_result = File.open("spec/fixtures/lint-result-with-everything.xml")
          allow(File).to receive(:open).with(Danger::DangerAndroidLint::REPORT_FILE).and_return(fake_result)

          @android_lint.lint

          markdown = @android_lint.status_report[:markdowns].first.message
          expect(markdown).to include("AndroidLint found issues")

          expect(markdown).to include("Fatal (1)")
          expect(markdown).to include("`AvatarView.java` | 60 | Implicitly using the default locale is a common source of bugs: Use `toUpperCase(Locale)` instead")

          expect(markdown).to include("Error (1)")
          expect(markdown).to include("`Events.java` | 21 | Implicitly using the default locale is a common source of bugs: Use `String.format(Locale, ...)` instead")

          expect(markdown).to include("Warning (1)")
          expect(markdown).to include("`Events.java` | 24 | Implicitly using the default locale is a common source of bugs: Use `String.format(Locale, ...)` instead")
        end

        it 'Doesn`t print anything if no errors were found' do
          fake_result = File.open("spec/fixtures/lint-result-empty.xml")
          allow(File).to receive(:open).with(Danger::DangerAndroidLint::REPORT_FILE).and_return(fake_result)

          @android_lint.lint

          markdown = @android_lint.status_report[:markdowns].first
          expect(markdown).to be_nil
        end

        it 'Doesn`t print anything if no errors were found' do
          fake_result = File.open("spec/fixtures/lint-result-without-fatal.xml")
          allow(File).to receive(:open).with(Danger::DangerAndroidLint::REPORT_FILE).and_return(fake_result)

          @android_lint.severity = "Fatal"
          @android_lint.lint

          markdown = @android_lint.status_report[:markdowns].first
          expect(markdown).to be_nil
        end

      end

    end
  end
end
