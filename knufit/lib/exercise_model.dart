// exercise_model.dart

class Exercise {
  final String name;
  final String tip;
  final String category;
  final String movement;
  final String precautions;
  final String gif;
  final int id;
  final String target;
  final String preparation;
  final String breathing;
  final String img;

  Exercise({
    required this.name,
    required this.tip,
    required this.category,
    required this.movement,
    required this.precautions,
    required this.gif,
    required this.id,
    required this.target,
    required this.preparation,
    required this.breathing,
    required this.img,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'] ?? '운동 이름',
      tip: json['tip'] ?? '',
      category: json['category'] ?? '',
      movement: json['movement'] ?? '',
      precautions: json['precautions'] ?? '',
      gif: json['gif'] ?? '',
      id: json['id'] ?? 0,
      target: json['target'] ?? '',
      preparation: json['preparation'] ?? '',
      breathing: json['breathing'] ?? '',
      img: json['img'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'tip': tip,
      'category': category,
      'movement': movement,
      'precautions': precautions,
      'gif': gif,
      'id': id,
      'target': target,
      'preparation': preparation,
      'breathing': breathing,
      'img': img,
    };
  }
}
