import 'package:json_annotation/json_annotation.dart';

/// Direction for calendar synchronization.
@JsonEnum(valueField: 'value')
enum SyncDirection {
  @JsonValue('bidirectional')
  bidirectional('bidirectional', 'Bidirectional'),

  @JsonValue('import_only')
  importOnly('import_only', 'Import Only'),

  @JsonValue('export_only')
  exportOnly('export_only', 'Export Only');

  const SyncDirection(this.value, this.label);

  final String value;
  final String label;
}
