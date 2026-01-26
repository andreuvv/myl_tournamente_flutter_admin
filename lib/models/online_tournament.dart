class OnlineTournament {
  final int id;
  final String name;
  final String month;
  final int year;
  final String format; // 'PB' or 'BF'
  final String type; // 'ONLINE'
  final String? startDate;
  final String? endDate;
  final String createdAt;

  OnlineTournament({
    required this.id,
    required this.name,
    required this.month,
    required this.year,
    required this.format,
    required this.type,
    this.startDate,
    this.endDate,
    required this.createdAt,
  });

  factory OnlineTournament.fromJson(Map<String, dynamic> json) {
    return OnlineTournament(
      id: json['id'] as int,
      name: json['name'] as String,
      month: json['month'] as String,
      year: json['year'] as int,
      format: json['format'] as String,
      type: json['type'] as String,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'month': month,
      'year': year,
      'format': format,
      'type': type,
      'start_date': startDate,
      'end_date': endDate,
      'created_at': createdAt,
    };
  }
}
