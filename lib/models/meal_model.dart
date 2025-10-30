class Meal {
  final String judul;
  final String? linkGambar;

  Meal({required this.judul, this.linkGambar});

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      judul: json['strMeal'] as String,
      linkGambar: json['strMealThumb'] as String?,
    );
  }
}