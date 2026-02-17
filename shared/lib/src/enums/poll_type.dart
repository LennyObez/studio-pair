import 'package:json_annotation/json_annotation.dart';

/// Type of poll voting mechanism.
@JsonEnum(valueField: 'value')
enum PollType {
  @JsonValue('single_choice')
  singleChoice('single_choice', 'Single Choice'),

  @JsonValue('multiple_choice')
  multipleChoice('multiple_choice', 'Multiple Choice'),

  @JsonValue('ranked_choice')
  rankedChoice('ranked_choice', 'Ranked Choice');

  const PollType(this.value, this.label);

  final String value;
  final String label;
}
