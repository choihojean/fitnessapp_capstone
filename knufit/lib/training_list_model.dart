// training_list_model.dart
class TrainingListItem {
  final int id;
  final int userId;
  final String name;

  TrainingListItem({
    required this.id,
    required this.userId,
    required this.name,
  });

  factory TrainingListItem.fromJson(Map<String, dynamic> json) {
    return TrainingListItem(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
    );
  }
}
