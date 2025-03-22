
class Task {
  String title = "";
  String? details;
  DateTime? deadline;
  Task? parent;
  int difficulty;
  double? latitude;
  double? longitude;
  int list;
  bool favorite = false;
  bool done = false;
  int id = 0;

  Task({
    required this.title,
    this.details,
    this.deadline,
    this.parent,
    required this.difficulty,
    this.latitude,
    this.longitude,
    required this.list,
    this.favorite = false,
    this.done = false,
    this.id = 0
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'] ?? "",
      details: json['details'],
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      parent: json['parent'] != null ? Task.fromJson(json['parent']) : null,
      difficulty: json['difficulty'],
      latitude: json['lat'],
      longitude: json['lng'],
      list: json['list'],
      favorite: json['favourite'] ?? false,
      done: json['done'] ?? false,
      id: json['id']
    );
  }

}