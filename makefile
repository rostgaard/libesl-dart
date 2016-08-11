all: dependencies

dependencies:
	pub get

tests:
	pub run test 

tests-to-json-file:
	-pub run test --reporter json > test-report.json

analyze:
	@dartanalyzer --no-hints --fatal-warnings --package-warnings lib/esl.dart
	@dartanalyzer --no-hints --fatal-warnings --package-warnings example/*.dart

analyze-hints:
	@echo "! (dartanalyzer --package-warnings lib/esl.dart | grep '^\[')" | bash
	@echo "! (dartanalyzer --package-warnings example/*.dart | grep '^\[')" | bash

analyze-all: analyze analyze-hints
