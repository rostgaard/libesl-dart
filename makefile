all: dependencies

dependencies:
	pub get

tests:
	@(cd test; dart esl-packet_transformer.dart)

analyze:
	@dartanalyzer --no-hints --fatal-warnings --package-warnings lib/esl.dart

analyze-hints:
	@echo "! (dartanalyzer --package-warnings lib/esl.dart | grep '^\[')" | bash; echo $?

analyze-all: analyze analyze-hints
