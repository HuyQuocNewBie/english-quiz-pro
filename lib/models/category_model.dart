class CategoryModel {
  final String id;
  final String name;
  final int questionCount;

  CategoryModel({
    required this.id,
    required this.name,
    this.questionCount = 0,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> data, String id) {
    return CategoryModel(
      id: id,
      name: data['name'] ?? '',
      questionCount: data['questionCount'] ?? 0,
    );
  }
}