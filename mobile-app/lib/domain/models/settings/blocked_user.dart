// Model class representing a blocked user in the application
class BlockedUser {
  final String id;
  final String name;
  final int age;
  final String location;
  final String photoUrl;
  final DateTime blockedAt;
  final String? blockReason;
  final double? distance;

  const BlockedUser({
    required this.id,
    required this.name,
    required this.age,
    required this.location,
    required this.photoUrl,
    required this.blockedAt,
    this.blockReason,
    this.distance,
  });

  // Create a BlockedUser from JSON data
  factory BlockedUser.fromJson(Map<String, dynamic> json) {
    return BlockedUser(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      location: json['location'] as String,
      photoUrl: json['photoUrl'] as String,
      blockedAt: DateTime.parse(json['blockedAt'] as String),
      blockReason: json['blockReason'] as String?,
      distance: json['distance'] as double?,
    );
  }

  // Convert BlockedUser to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'location': location,
      'photoUrl': photoUrl,
      'blockedAt': blockedAt.toIso8601String(),
      'blockReason': blockReason,
      'distance': distance,
    };
  }

  // Create a copy of BlockedUser with optional new values
  BlockedUser copyWith({
    String? id,
    String? name,
    int? age,
    String? location,
    String? photoUrl,
    DateTime? blockedAt,
    String? blockReason,
    double? distance,
  }) {
    return BlockedUser(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      location: location ?? this.location,
      photoUrl: photoUrl ?? this.photoUrl,
      blockedAt: blockedAt ?? this.blockedAt,
      blockReason: blockReason ?? this.blockReason,
      distance: distance ?? this.distance,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BlockedUser &&
      other.id == id &&
      other.name == name &&
      other.age == age &&
      other.location == location &&
      other.photoUrl == photoUrl &&
      other.blockedAt == blockedAt &&
      other.blockReason == blockReason &&
      other.distance == distance;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      age.hashCode ^
      location.hashCode ^
      photoUrl.hashCode ^
      blockedAt.hashCode ^
      blockReason.hashCode ^
      (distance?.hashCode ?? 0);
  }
}
