class Tag{
  String tag;
  bool isChecked;

  Tag({
    required this.tag,
    required this.isChecked
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      tag: json["tag"],
      isChecked: json["is_checked"],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'tag' : tag,
      'is_checked' : isChecked,
    };
  }

}