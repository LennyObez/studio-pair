import 'package:json_annotation/json_annotation.dart';

/// Status of a file virus/malware scan.
@JsonEnum(valueField: 'value')
enum FileScanStatus {
  @JsonValue('pending')
  pending('pending', 'Pending'),

  @JsonValue('clean')
  clean('clean', 'Clean'),

  @JsonValue('infected')
  infected('infected', 'Infected');

  const FileScanStatus(this.value, this.label);

  final String value;
  final String label;
}
