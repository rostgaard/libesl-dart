all: dependencies

dependencies:
	pub get

tests:
	@(cd test; dart all_test.dart)

analyze:
	@dartanalyzer --no-hints --fatal-warnings --package-warnings lib/esl.dart
	@dartanalyzer --no-hints --fatal-warnings --package-warnings examples/*.dart

analyze-hints:
	@echo "! (dartanalyzer --package-warnings lib/esl.dart | grep '^\[')" | bash
	@echo "! (dartanalyzer --package-warnings examples/*.dart | grep '^\[')" | bash

analyze-all: analyze analyze-hints
