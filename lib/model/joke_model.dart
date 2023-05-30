class JokeList {
  final String category;
  final String type;
  final String setup;
  final String delivery;
  bool addToBookMark;

  JokeList(
      {required this.category,
      required this.type,
      required this.setup,
      required this.delivery,
      this.addToBookMark = false});

  factory JokeList.fromJson(Map<String, dynamic> json) {
    return JokeList(
      category: json['category'],
      type: json['type'],
      setup: json['setup'],
      delivery: json['delivery'],
      addToBookMark: json['addToBookMark'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'setup': setup,
      'type': type,
      'category': category,
      'delivery': delivery,
      'addToBookMark': addToBookMark,
    };
  }


}
