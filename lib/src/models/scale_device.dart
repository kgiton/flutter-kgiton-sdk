/// Model untuk perangkat timbangan
class ScaleDevice {
  final String name;
  final String id;
  final int rssi;
  final String? licenseKey; // License key yang berhasil connect (opsional)

  ScaleDevice({required this.name, required this.id, required this.rssi, this.licenseKey});

  factory ScaleDevice.fromBleDevice(String name, String id, int rssi, {String? licenseKey}) {
    return ScaleDevice(name: name, id: id, rssi: rssi, licenseKey: licenseKey);
  }

  /// Copy device dengan data baru
  ScaleDevice copyWith({String? name, String? id, int? rssi, String? licenseKey}) {
    return ScaleDevice(name: name ?? this.name, id: id ?? this.id, rssi: rssi ?? this.rssi, licenseKey: licenseKey ?? this.licenseKey);
  }

  /// Konversi ke Map untuk storage
  Map<String, dynamic> toMap() {
    return {'name': name, 'id': id, 'rssi': rssi, 'licenseKey': licenseKey};
  }

  /// Konversi dari Map untuk storage
  factory ScaleDevice.fromMap(Map<String, dynamic> map) {
    return ScaleDevice(name: map['name'] as String, id: map['id'] as String, rssi: map['rssi'] as int, licenseKey: map['licenseKey'] as String?);
  }

  @override
  String toString() => 'ScaleDevice(name: $name, id: $id, rssi: $rssi, licenseKey: ${licenseKey != null ? "***" : "null"})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScaleDevice && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
