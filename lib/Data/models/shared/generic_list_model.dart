class GenericListModel {
  final String? key;
  final int? id;
  final String? name;
  final String? nameAr;
  final String? categoryType;
  final String? text;
  final int? isPackaging;
  final String? totalAmount;

  const GenericListModel({
    this.key,
    this.id,
    this.name,
    this.nameAr,
    this.categoryType,
    this.text,
    this.isPackaging,
    this.totalAmount,
  });

  factory GenericListModel.fromJson(Map<String, dynamic> json) {
    return GenericListModel(
      key: json['key'] as String?,
      id: json['id'] as int?,
      name: json['name'] as String?,
      nameAr: json['name_ar'] as String?,
      categoryType: json['category_type'] as String?,
      text: json['text'] as String?,
      isPackaging: json['is_packaging'] as int?,
      totalAmount: json['total_amount'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (key != null) 'key': key,
        if (id != null) 'id': id,
        if (name != null) 'name': name,
        if (nameAr != null) 'name_ar': nameAr,
        if (categoryType != null) 'category_type': categoryType,
        if (text != null) 'text': text,
        if (isPackaging != null) 'is_packaging': isPackaging,
        if (totalAmount != null) 'total_amount': totalAmount,
      };

  GenericListModel copyWith({
    String? key,
    int? id,
    String? name,
    String? nameAr,
    String? categoryType,
    String? text,
    int? isPackaging,
    String? totalAmount,
  }) {
    return GenericListModel(
      key: key ?? this.key,
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      categoryType: categoryType ?? this.categoryType,
      text: text ?? this.text,
      isPackaging: isPackaging ?? this.isPackaging,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}

List<GenericListModel> parseGenericList(List<dynamic> json) {
  return json.map((e) => GenericListModel.fromJson(e)).toList();
}

T findById<T extends GenericListModel>(List<T> list, int id) {
  return list.firstWhere(
    (e) => e.id == id,
    orElse: () => throw Exception('Item with id $id not found'),
  );
}
