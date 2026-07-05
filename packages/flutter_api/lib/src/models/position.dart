class Position {
  final String id;
  final String organizationId;
  final String name;
  final String status;

  Position({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.status,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      id: json['id'] as String,
      organizationId: json['organizationId'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
    );
  }
}
