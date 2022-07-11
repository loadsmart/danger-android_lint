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
        allow(@android_lint.git).to receive(:deleted_files).and_return([])
        allow(@android_lint.git).to receive(:added_files).and_return([])
        allow(@android_lint.git).to receive(:modified_files).and_return([
          "/Users/gustavo/Developer/app-android/app/src/main/java/com/loadsmart/common/views/AvatarView.java",
          "/Users/gustavo/Developer/app-android/app/src/main/java/com/loadsmart/analytics/Events.java"
        ])
      end

      it "Fails if gradlew does not exist" do
        allow(@android_lint).to receive(:`).with("ls gradlew").and_return("")

        @android_lint.lint
        expect(@android_lint.status_report[:errors]).to eq(["Could not find `gradlew` inside current directory"])
      end

      it "Set custom Gradle task" do
        custom_task = "lintRelease"
        @android_lint.gradle_task = custom_task
        expect(@android_lint.gradle_task).to eq(custom_task)
      end

      it "Check default Gradle task" do
        expect(@android_lint.gradle_task).to eq("lint")
      end

      it "Skip Gradle task" do
        skip_gradle_task = true
        @android_lint.skip_gradle_task = skip_gradle_task
        expect(@android_lint.skip_gradle_task).to eq(skip_gradle_task)
      end

      it "Check default skip Gradle task" do
        expect(@android_lint.skip_gradle_task).to eq(false)
      end

      it "Fails if severity is an unknown value" do
        allow(@android_lint).to receive(:`).with("ls gradlew").and_return("gradlew")
        allow(File).to receive(:exists?).with(@android_lint.report_file()).and_return(true)

        @android_lint.severity = "Dummy"
        @android_lint.lint

        expect(@android_lint.status_report[:errors]).to eq(["'Dummy' is not a valid value for `severity` parameter."])
      end

      it "Sets severity to 'Warning' if no severity param is provided" do
        allow(@android_lint).to receive(:`).with("ls gradlew").and_return("gradlew")
        allow(File).to receive(:exists?).with(@android_lint.report_file).and_return(true)

        fake_result = File.open("spec/fixtures/lint-result-with-everything.xml")
        allow(File).to receive(:open).with(@android_lint.report_file).and_return(fake_result)

        @android_lint.lint
        expect(@android_lint.severity).to eq("Warning")
      end

      it "Sets the report file to a default location if no param is provided" do
        allow(@android_lint).to receive(:`).with("ls gradlew").and_return("gradlew")
        allow(File).to receive(:exists?).with(@android_lint.report_file).and_return(true)

        fake_result = File.open("spec/fixtures/lint-result-with-everything.xml")
        allow(File).to receive(:open).with(@android_lint.report_file).and_return(fake_result)

        @android_lint.lint
        expect(@android_lint.report_file).to eq("app/build/reports/lint/lint-result.xml")
      end

      it "Sets the report_file to the user's preference in the Dangerfile'" do
        allow(@android_lint).to receive(:`).with("ls gradlew").and_return("gradlew")

        @android_lint.report_file = 'some/other/location/lint-result.xml'

        fake_result = File.open("spec/fixtures/lint-result-with-everything.xml")
        allow(File).to receive(:open).with(@android_lint.report_file).and_return(fake_result)
        allow(File).to receive(:exists?).with(@android_lint.report_file).and_return(true)

        @android_lint.lint

        expect(@android_lint.report_file).to eq('some/other/location/lint-result.xml')
      end

      it "Fails if report file does not exist" do
        allow(@android_lint).to receive(:`).with("ls gradlew").and_return("gradlew")
        allow(File).to receive(:exists?).with(@android_lint.report_file).and_return(false)

        fake_result = File.open("spec/fixtures/lint-result-with-everything.xml")
        allow(File).to receive(:open).with(@android_lint.report_file).and_return(fake_result)

        @android_lint.lint

        expect(@android_lint.status_report[:errors]).to eq(["Lint report not found at `app/build/reports/lint/lint-result.xml`. "\
          "Have you forgot to add `xmlReport true` to your `build.gradle` file?"])
      end

      describe 'lint' do
        before do
          allow(@android_lint).to receive(:`).with("ls gradlew").and_return("gradlew")
          allow(File).to receive(:exists?).with(@android_lint.report_file).and_return(false)
        end

        it 'Prints markdown if issues were found' do
          fake_result = File.open("spec/fixtures/lint-result-with-special-chars.xml")
          allow(File).to receive(:open).with(@android_lint.report_file).and_return(fake_result)

          @android_lint.lint

          markdown = @android_lint.status_report[:markdowns].first.message
          expect(markdown).to include("AndroidLint found issues")

          expect(markdown).to include("Warning (1)")
          expect(markdown).to include("`app/src/main/res/values/strings.xml` | 105 | The resource `R.string.authentication_invalid_auth_token_type` appears to be unused")
        end

        it 'Prints markdown if issues were found even if there is a special char' do
          fake_result = File.open("spec/fixtures/lint-result-with-everything.xml")
          allow(File).to receive(:open).with(@android_lint.report_file).and_return(fake_result)

          @android_lint.lint

          markdown = @android_lint.status_report[:markdowns].first.message
          expect(markdown).to include("AndroidLint found issues")

          expect(markdown).to include("Fatal (1)")
          expect(markdown).to include("`/Users/gustavo/Developer/app-android/app/src/main/java/com/loadsmart/common/views/AvatarView.java` | 60 | Implicitly using the default locale is a common source of bugs: Use `toUpperCase(Locale)` instead")
        end

        it 'Doesn`t print anything if no errors were found' do
          fake_result = File.open("spec/fixtures/lint-result-empty.xml")
          allow(File).to receive(:open).with(@android_lint.report_file).and_return(fake_result)

          @android_lint.lint

          markdown = @android_lint.status_report[:markdowns].first
          expect(markdown).to be_nil
        end

        it 'Doesn`t print anything if no errors were found at the set minimum severity level' do
          fake_result = File.open("spec/fixtures/lint-result-without-fatal.xml")
          allow(File).to receive(:open).with(@android_lint.report_file).and_return(fake_result)

          @android_lint.severity = "Fatal"
          @android_lint.lint

          markdown = @android_lint.status_report[:markdowns].first
          expect(markdown).to be_nil
        end

        it 'Send inline comment instead of markdown' do
          fake_result = File.open("spec/fixtures/lint-result-with-everything.xml")
          allow(File).to receive(:open).with(@android_lint.report_file).and_return(fake_result)

          @android_lint.lint inline_mode: true
          error = @android_lint.status_report[:errors]
          expect(error).to include("Implicitly using the default locale is a common source of bugs: Use `toUpperCase(Locale)` instead")
          expect(error).to include("Implicitly using the default locale is a common source of bugs: Use `String.format(Locale, ...)` instead")

          warn = @android_lint.status_report[:warnings]
          expect(warn).to include("Implicitly using the default locale is a common source of bugs: Use `String.format(Locale, ...)` instead")
        end

        it 'Only show comment in changed files' do
          allow(@android_lint.git).to receive(:modified_files).and_return([
          "/Users/gustavo/Developer/app-android/app/src/main/java/com/loadsmart/common/views/AvatarView.java",
          ])

          fake_result = File.open("spec/fixtures/lint-result-with-everything.xml")
          allow(File).to receive(:open).with(@android_lint.report_file).and_return(fake_result)

          @android_lint.filtering = true
          @android_lint.lint inline_mode: true
          error = @android_lint.status_report[:errors]
          expect(error).to include("Implicitly using the default locale is a common source of bugs: Use `toUpperCase(Locale)` instead")
          expect(error).not_to include("Implicitly using the default locale is a common source of bugs: Use `String.format(Locale, ...)` instead")

          warn = @android_lint.status_report[:warnings]
          expect(warn).not_to include("Implicitly using the default locale is a common source of bugs: Use `String.format(Locale, ...)` instead")
        end

        describe 'excluding_issue_ids' do
          before do
            fake_result = File.open("spec/fixtures/lint-result-with-everything.xml")
            allow(File).to receive(:open).with(@android_lint.report_file).and_return(fake_result)
          end

          it 'Does not print ignored issues' do
            @android_lint.excluding_issue_ids = ["MissingTranslation", "RtlEnabled"]
            @android_lint.lint

            markdown = @android_lint.status_report[:markdowns].first.message
            expect(markdown).to include("Implicitly using the default locale")
            expect(markdown).not_to include("is not translated in")
            expect(markdown).not_to include("The project references RTL attributes, but does not explicitly enable or disable RTL support with `android:supportsRtl` in the manifest")
          end
        end

        describe "for a modified file" do
          before do
            allow(Dir).to receive(:pwd).and_return("/Users/shivampokhriyal/Documents/projects/Commcare/commcare-android")

            allow(@android_lint.git).to receive(:modified_files).and_return([
              "app/build.gradle",
            ])

            fake_patch = File.read("spec/fixtures/pr-diff.diff")
            diff = [OpenStruct.new(type: "modified", path: "app/build.gradle")]
            allow(@android_lint.git).to receive(:diff).and_return(diff)
            diff_for_file = OpenStruct.new(insertions: 3)
            allow(diff).to receive(:[]).with("app/build.gradle").and_return(diff_for_file)
            allow(diff_for_file).to receive(:patch).and_return(fake_patch)

            fake_result = File.open("spec/fixtures/lint-result-for-pr.xml")
            allow(File).to receive(:open).with(@android_lint.report_file).and_return(fake_result)
          end

          context 'when inline_mode: true' do
            it 'with filtering_lines, only show issues in modified lines' do
              @android_lint.filtering_lines = true
              @android_lint.lint inline_mode: true

              error = @android_lint.status_report[:errors]
              expect(error).to include("fake message three")

              expect(error).not_to include("fake message one")
              expect(error).not_to include("fake message two")
              expect(error).not_to include("fake message in unmodified file")
            end

            it 'with filtering, show all issues in modified files' do
              @android_lint.filtering = true
              @android_lint.lint inline_mode: true

              error = @android_lint.status_report[:errors]
              expect(error).to include("fake message one")
              expect(error).to include("fake message two")
              expect(error).to include("fake message three")

              expect(error).not_to include("fake message in unmodified file")
            end
          end

          context 'when inline_mode: false' do
            it 'with filtering_lines, only show issues in modified lines' do
              @android_lint.filtering_lines = true
              @android_lint.lint inline_mode: false

              puts @android_lint.status_report[:markdowns]
              message = @android_lint.status_report[:markdowns][0].to_s
              expect(message).to include("fake message three")

              expect(message).not_to include("fake message one")
              expect(message).not_to include("fake message two")
              expect(message).not_to include("fake message in unmodified file")
            end

            it 'with filtering, show all issues in modified files' do
              @android_lint.filtering = true
              @android_lint.lint inline_mode: false

              message = @android_lint.status_report[:markdowns][0].to_s
              expect(message).to include("fake message one")
              expect(message).to include("fake message two")
              expect(message).to include("fake message three")

              expect(message).not_to include("fake message in unmodified file")
            end
          end
        end
      end
    end
  end
end
