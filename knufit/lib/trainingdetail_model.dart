// trainingdetail_model.dart

class TrainingDetailItem {
  final TrainingListDetail trainingListDetail;
  final Training training;

  TrainingDetailItem({
    required this.trainingListDetail,
    required this.training,
  });

  // Factory constructor to create an instance from JSON
  factory TrainingDetailItem.fromJson(Map<String, dynamic> json) {
    return TrainingDetailItem(
      trainingListDetail: TrainingListDetail.fromJson(json['training_list_detail']),
      training: Training.fromJson(json['training']),
    );
  }

  // Method to convert the instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'training_list_detail': trainingListDetail.toJson(),
      'training': training.toJson(),
    };
  }
}

class TrainingListDetail {
  final int id;
  final int trainingId;
  final int userId;
  String content;
  final int trainingListId;

  TrainingListDetail({
    required this.id,
    required this.trainingId,
    required this.userId,
    required this.content,
    required this.trainingListId,
  });

  // Factory constructor to create an instance from JSON
  factory TrainingListDetail.fromJson(Map<String, dynamic> json) {
    return TrainingListDetail(
      id: json['id'],
      trainingId: json['training_id'],
      userId: json['user_id'],
      content: json['content'],
      trainingListId: json['training_list_id'],
    );
  }

  // Method to convert the instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'training_id': trainingId,
      'user_id': userId,
      'content': content,
      'training_list_id': trainingListId,
    };
  }
}

class Training {
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

  Training({
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

  // Factory constructor to create an instance from JSON
  factory Training.fromJson(Map<String, dynamic> json) {
    return Training(
      name: json['name'],
      tip: json['tip'],
      category: json['category'],
      movement: json['movement'],
      precautions: json['precautions'],
      gif: json['gif'],
      id: json['id'],
      target: json['target'],
      preparation: json['preparation'],
      breathing: json['breathing'],
      img: json['img'],
    );
  }

  // Method to convert the instance to JSON
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
