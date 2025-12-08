class Player {
  final int id;
  final String name;
  final bool confirmed;
  final String? createdAt;
  final String? updatedAt;

  Player({
    required this.id,
    required this.name,
    required this.confirmed,
    this.createdAt,
    this.updatedAt,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as int,
      name: json['name'] as String,
      confirmed: json['confirmed'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'confirmed': confirmed,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  Player copyWith({
    int? id,
    String? name,
    bool? confirmed,
    String? createdAt,
    String? updatedAt,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      confirmed: confirmed ?? this.confirmed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
