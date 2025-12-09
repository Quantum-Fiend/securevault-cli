import 'dart:convert';

/// Password entry model
class PasswordEntry {
  final String id;
  String service;
  String username;
  String password;
  String notes;
  List<String> tags;
  final DateTime createdAt;
  DateTime modifiedAt;
  DateTime lastRotated;

  PasswordEntry({
    required this.id,
    required this.service,
    required this.username,
    required this.password,
    this.notes = '',
    List<String>? tags,
    DateTime? createdAt,
    DateTime? modifiedAt,
    DateTime? lastRotated,
  })  : tags = tags ?? [],
        createdAt = createdAt ?? DateTime.now(),
        modifiedAt = modifiedAt ?? DateTime.now(),
        lastRotated = lastRotated ?? DateTime.now();

  /// Get password age in days
  int get passwordAge {
    return DateTime.now().difference(lastRotated).inDays;
  }

  /// Check if password needs rotation (older than 90 days)
  bool get needsRotation => passwordAge > 90;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service': service,
      'username': username,
      'password': password,
      'notes': notes,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'lastRotated': lastRotated.toIso8601String(),
    };
  }

  /// Create from JSON
  factory PasswordEntry.fromJson(Map<String, dynamic> json) {
    return PasswordEntry(
      id: json['id'] as String,
      service: json['service'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      notes: json['notes'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
      lastRotated: DateTime.parse(json['lastRotated'] as String),
    );
  }

  /// Create a copy with updated fields
  PasswordEntry copyWith({
    String? service,
    String? username,
    String? password,
    String? notes,
    List<String>? tags,
    DateTime? modifiedAt,
    DateTime? lastRotated,
  }) {
    return PasswordEntry(
      id: id,
      service: service ?? this.service,
      username: username ?? this.username,
      password: password ?? this.password,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      modifiedAt: modifiedAt ?? DateTime.now(),
      lastRotated: lastRotated ?? this.lastRotated,
    );
  }

  @override
  String toString() {
    return 'PasswordEntry(service: $service, username: $username)';
  }
}

/// Activity log entry
class ActivityLogEntry {
  final String type;
  final String description;
  final DateTime timestamp;

  ActivityLogEntry({
    required this.type,
    required this.description,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ActivityLogEntry.fromJson(Map<String, dynamic> json) {
    return ActivityLogEntry(
      type: json['type'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// Vault metadata
class VaultMetadata {
  final String name;
  final String version;
  final String kdfType;
  final int iterations;
  final DateTime createdAt;
  DateTime lastModified;
  int entryCount;
  bool hasRecoveryKey;
  String? recoveryKeyHash;

  VaultMetadata({
    required this.name,
    this.version = '1.0.0',
    this.kdfType = 'pbkdf2',
    this.iterations = 100000,
    DateTime? createdAt,
    DateTime? lastModified,
    this.entryCount = 0,
    this.hasRecoveryKey = false,
    this.recoveryKeyHash,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastModified = lastModified ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'version': version,
      'kdfType': kdfType,
      'iterations': iterations,
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'entryCount': entryCount,
      'hasRecoveryKey': hasRecoveryKey,
      'recoveryKeyHash': recoveryKeyHash,
    };
  }

  factory VaultMetadata.fromJson(Map<String, dynamic> json) {
    return VaultMetadata(
      name: json['name'] as String,
      version: json['version'] as String? ?? '1.0.0',
      kdfType: json['kdfType'] as String? ?? 'pbkdf2',
      iterations: json['iterations'] as int? ?? 100000,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastModified: DateTime.parse(json['lastModified'] as String),
      entryCount: json['entryCount'] as int? ?? 0,
      hasRecoveryKey: json['hasRecoveryKey'] as bool? ?? false,
      recoveryKeyHash: json['recoveryKeyHash'] as String?,
    );
  }
}

/// Vault data structure
class VaultData {
  final VaultMetadata metadata;
  final List<PasswordEntry> entries;
  final List<ActivityLogEntry> activityLog;

  VaultData({
    required this.metadata,
    List<PasswordEntry>? entries,
    List<ActivityLogEntry>? activityLog,
  })  : entries = entries ?? [],
        activityLog = activityLog ?? [];

  Map<String, dynamic> toJson() {
    return {
      'metadata': metadata.toJson(),
      'entries': entries.map((e) => e.toJson()).toList(),
      'activityLog': activityLog.map((e) => e.toJson()).toList(),
    };
  }

  factory VaultData.fromJson(Map<String, dynamic> json) {
    return VaultData(
      metadata: VaultMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
      entries: (json['entries'] as List<dynamic>)
          .map((e) => PasswordEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      activityLog: (json['activityLog'] as List<dynamic>)
          .map((e) => ActivityLogEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory VaultData.fromJsonString(String jsonString) {
    return VaultData.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }
}
