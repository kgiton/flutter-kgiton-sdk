/// Model untuk data berat dari timbangan
class WeightData {
  final double weight;
  final DateTime timestamp;
  final String unit;

  WeightData({required this.weight, DateTime? timestamp, this.unit = 'kg'}) : timestamp = timestamp ?? DateTime.now();

  /// Raw weight value tanpa formatting
  double get rawWeight => weight;

  /// Format berat sebagai string dengan 3 desimal
  String get formattedWeight => weight.toStringAsFixed(3);

  /// Berat dalam string dengan satuan
  String get displayWeight => '$formattedWeight $unit';

  @override
  String toString() => 'WeightData(weight: $formattedWeight $unit, time: $timestamp)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeightData && other.weight == weight && other.timestamp == timestamp && other.unit == unit;
  }

  @override
  int get hashCode => Object.hash(weight, timestamp, unit);
}
