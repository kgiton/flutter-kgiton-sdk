import 'api_response.dart' show Pagination;

/// License model
class License {
  final String id;
  final String licenseKey;
  final bool isUsed;
  final String? assignedTo;
  final DateTime createdAt;
  final DateTime? updatedAt;

  License({required this.id, required this.licenseKey, required this.isUsed, this.assignedTo, required this.createdAt, this.updatedAt});

  factory License.fromJson(Map<String, dynamic> json) {
    return License(
      id: json['id'] as String,
      licenseKey: json['license_key'] as String,
      isUsed: json['is_used'] as bool,
      assignedTo: json['assigned_to'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'license_key': licenseKey,
      'is_used': isUsed,
      if (assignedTo != null) 'assigned_to': assignedTo,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}

/// License list data with pagination
class LicenseListData {
  final List<License> licenses;
  final Pagination? pagination;

  LicenseListData({required this.licenses, this.pagination});

  factory LicenseListData.fromJson(dynamic json) {
    // Handle if response is a List directly
    if (json is List) {
      final licenses = json.map((e) => License.fromJson(e as Map<String, dynamic>)).toList();
      return LicenseListData(licenses: licenses, pagination: null);
    }

    // Handle if response is an Object with 'licenses' property
    if (json is Map<String, dynamic>) {
      return LicenseListData(
        licenses: (json['licenses'] as List).map((e) => License.fromJson(e as Map<String, dynamic>)).toList(),
        pagination: json['pagination'] != null ? Pagination.fromJson(json['pagination'] as Map<String, dynamic>) : null,
      );
    }

    throw FormatException('Invalid LicenseListData format');
  }

  Map<String, dynamic> toJson() {
    return {'licenses': licenses.map((e) => e.toJson()).toList(), if (pagination != null) 'pagination': pagination!.toJson()};
  }
}

// Pagination is exported from api_response.dart
// No need to duplicate here

/// Bulk create licenses data
class BulkLicenseData {
  final int count;
  final int failed;
  final List<License> licenses;

  BulkLicenseData({required this.count, required this.failed, required this.licenses});

  factory BulkLicenseData.fromJson(Map<String, dynamic> json) {
    return BulkLicenseData(
      count: json['count'] as int,
      failed: json['failed'] as int,
      licenses: (json['licenses'] as List).map((e) => License.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'count': count, 'failed': failed, 'licenses': licenses.map((e) => e.toJson()).toList()};
  }
}

/// Owner licenses data
class OwnerLicensesData {
  final List<License> licenses;
  final int count;

  OwnerLicensesData({required this.licenses, required this.count});

  factory OwnerLicensesData.fromJson(dynamic json) {
    // Handle if response is a List directly
    if (json is List) {
      final licenses = json.map((e) => License.fromJson(e as Map<String, dynamic>)).toList();
      return OwnerLicensesData(licenses: licenses, count: licenses.length);
    }

    // Handle if response is an Object with 'licenses' property
    if (json is Map<String, dynamic>) {
      return OwnerLicensesData(
        licenses: (json['licenses'] as List).map((e) => License.fromJson(e as Map<String, dynamic>)).toList(),
        count: json['count'] as int,
      );
    }

    throw FormatException('Invalid OwnerLicensesData format');
  }

  Map<String, dynamic> toJson() {
    return {'licenses': licenses.map((e) => e.toJson()).toList(), 'count': count};
  }
}

/// Create license request
class CreateLicenseRequest {
  final String? licenseKey;

  CreateLicenseRequest({this.licenseKey});

  Map<String, dynamic> toJson() {
    return {if (licenseKey != null) 'license_key': licenseKey};
  }
}

/// Bulk create licenses request
class BulkCreateLicensesRequest {
  final int count;

  BulkCreateLicensesRequest({required this.count});

  Map<String, dynamic> toJson() {
    return {'count': count};
  }
}

/// Assign license request
class AssignLicenseRequest {
  final String licenseKey;

  AssignLicenseRequest({required this.licenseKey});

  Map<String, dynamic> toJson() {
    return {'license_key': licenseKey};
  }
}
