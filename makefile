all: dependencies

dependencies:
	pub get

tests:
	(cd test; dart esl-packet_transformer.dart)
