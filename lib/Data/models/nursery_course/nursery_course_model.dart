import 'package:flutter/material.dart';

// ─── Content Type ─────────────────────────────────────────────────────────────

enum LessonContentType { text, video, pdf, image }

extension LessonContentTypeX on LessonContentType {
  String get label => switch (this) {
    LessonContentType.text  => 'نص',
    LessonContentType.video => 'فيديو',
    LessonContentType.pdf   => 'PDF',
    LessonContentType.image => 'صورة',
  };

  IconData get icon => switch (this) {
    LessonContentType.text  => Icons.article_rounded,
    LessonContentType.video => Icons.play_circle_rounded,
    LessonContentType.pdf   => Icons.picture_as_pdf_rounded,
    LessonContentType.image => Icons.image_rounded,
  };

  Color get color => switch (this) {
    LessonContentType.text  => const Color(0xFF5E35B1),
    LessonContentType.video => const Color(0xFFDC2626),
    LessonContentType.pdf   => const Color(0xFFD97706),
    LessonContentType.image => const Color(0xFF0891B2),
  };

  static LessonContentType fromString(String? v) =>
      LessonContentType.values.firstWhere(
        (e) => e.name == v,
        orElse: () => LessonContentType.text,
      );
}

// ─── Category ─────────────────────────────────────────────────────────────────

enum CourseCategory { language, math, art, quran, music, science, social }

extension CourseCategoryX on CourseCategory {
  String get label => switch (this) {
    CourseCategory.language => 'لغات',
    CourseCategory.math     => 'رياضيات',
    CourseCategory.art      => 'فنون',
    CourseCategory.quran    => 'قرآن كريم',
    CourseCategory.music    => 'موسيقى',
    CourseCategory.science  => 'علوم',
    CourseCategory.social   => 'مهارات اجتماعية',
  };

  Color get color => switch (this) {
    CourseCategory.language => const Color(0xFF2563EB),
    CourseCategory.math     => const Color(0xFFD97706),
    CourseCategory.art      => const Color(0xFFBE185D),
    CourseCategory.quran    => const Color(0xFF059669),
    CourseCategory.music    => const Color(0xFF7C3AED),
    CourseCategory.science  => const Color(0xFF0E7490),
    CourseCategory.social   => const Color(0xFF4D7C0F),
  };

  Color get accentColor => switch (this) {
    CourseCategory.language => const Color(0xFF60A5FA),
    CourseCategory.math     => const Color(0xFFFBBF24),
    CourseCategory.art      => const Color(0xFFF472B6),
    CourseCategory.quran    => const Color(0xFF34D399),
    CourseCategory.music    => const Color(0xFFA78BFA),
    CourseCategory.science  => const Color(0xFF38BDF8),
    CourseCategory.social   => const Color(0xFF86EFAC),
  };

  Color get lightColor => switch (this) {
    CourseCategory.language => const Color(0xFFEFF6FF),
    CourseCategory.math     => const Color(0xFFFFFBEB),
    CourseCategory.art      => const Color(0xFFFDF2F8),
    CourseCategory.quran    => const Color(0xFFECFDF5),
    CourseCategory.music    => const Color(0xFFF5F3FF),
    CourseCategory.science  => const Color(0xFFECFEFF),
    CourseCategory.social   => const Color(0xFFF7FEE7),
  };

  IconData get icon => switch (this) {
    CourseCategory.language => Icons.translate_rounded,
    CourseCategory.math     => Icons.calculate_rounded,
    CourseCategory.art      => Icons.palette_rounded,
    CourseCategory.quran    => Icons.auto_stories_rounded,
    CourseCategory.music    => Icons.music_note_rounded,
    CourseCategory.science  => Icons.science_rounded,
    CourseCategory.social   => Icons.people_alt_rounded,
  };

  LinearGradient get gradient => LinearGradient(
    colors: [color, accentColor],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static CourseCategory fromString(String? v) =>
      CourseCategory.values.firstWhere(
        (e) => e.name == v,
        orElse: () => CourseCategory.language,
      );
}

// ─── Lesson ───────────────────────────────────────────────────────────────────

class CourseLesson {
  final String id;
  final String courseId;
  final String title;
  final String? description;
  final int orderIndex;
  final int durationMinutes;
  final LessonContentType contentType;
  final String? contentUrl;
  final String? textContent;
  final int createdAt;

  const CourseLesson({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    required this.orderIndex,
    this.durationMinutes = 0,
    this.contentType = LessonContentType.text,
    this.contentUrl,
    this.textContent,
    required this.createdAt,
  });

  factory CourseLesson.fromJson(Map<String, dynamic> json, {required String id}) {
    return CourseLesson(
      id: id,
      courseId: json['courseId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      orderIndex: _parseInt(json['orderIndex']) ?? 0,
      durationMinutes: _parseInt(json['durationMinutes']) ?? 0,
      contentType: LessonContentTypeX.fromString(json['contentType']?.toString()),
      contentUrl: json['contentUrl']?.toString(),
      textContent: json['textContent']?.toString(),
      createdAt: _parseInt(json['createdAt']) ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'courseId': courseId,
      'title': title,
      'orderIndex': orderIndex,
      'durationMinutes': durationMinutes,
      'contentType': contentType.name,
      'createdAt': createdAt,
    };
    if (description != null) m['description'] = description;
    if (contentUrl != null) m['contentUrl'] = contentUrl;
    if (textContent != null) m['textContent'] = textContent;
    return m;
  }

  CourseLesson copyWith({
    String? id,
    String? courseId,
    String? title,
    String? description,
    int? orderIndex,
    int? durationMinutes,
    LessonContentType? contentType,
    String? contentUrl,
    String? textContent,
    int? createdAt,
  }) =>
      CourseLesson(
        id: id ?? this.id,
        courseId: courseId ?? this.courseId,
        title: title ?? this.title,
        description: description ?? this.description,
        orderIndex: orderIndex ?? this.orderIndex,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        contentType: contentType ?? this.contentType,
        contentUrl: contentUrl ?? this.contentUrl,
        textContent: textContent ?? this.textContent,
        createdAt: createdAt ?? this.createdAt,
      );

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

// ─── Course ───────────────────────────────────────────────────────────────────

class NurseryCourse {
  final String id;
  final String nurseryId;
  final String? branchId;
  // Empty list = available in all branches; otherwise restricted to these branch ids.
  final List<String> branchIds;
  final String title;
  final String description;
  final double price;
  final String? coverUrl;
  final CourseCategory category;
  final String ageGroup;
  final bool isActive;
  final int lessonCount;
  final int totalMinutes;
  final int createdAt;
  final int? updatedAt;

  const NurseryCourse({
    required this.id,
    required this.nurseryId,
    this.branchId,
    this.branchIds = const [],
    required this.title,
    required this.description,
    required this.price,
    this.coverUrl,
    required this.category,
    required this.ageGroup,
    this.isActive = true,
    this.lessonCount = 0,
    this.totalMinutes = 0,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isAllBranches => branchIds.isEmpty;

  factory NurseryCourse.fromJson(Map<String, dynamic> json, {required String id}) {
    return NurseryCourse(
      id: id,
      nurseryId: json['nurseryId']?.toString() ?? '',
      branchId: json['branchId']?.toString(),
      branchIds: _parseStringList(json['branchIds']),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: _parseDouble(json['price']) ?? 0,
      coverUrl: json['coverUrl']?.toString(),
      category: CourseCategoryX.fromString(json['category']?.toString()),
      ageGroup: json['ageGroup']?.toString() ?? '',
      isActive: json['isActive'] != false,
      lessonCount: _parseInt(json['lessonCount']) ?? 0,
      totalMinutes: _parseInt(json['totalMinutes']) ?? 0,
      createdAt: _parseInt(json['createdAt']) ?? DateTime.now().millisecondsSinceEpoch,
      updatedAt: _parseInt(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'nurseryId': nurseryId,
      'branchIds': branchIds,
      'title': title,
      'description': description,
      'price': price,
      'category': category.name,
      'ageGroup': ageGroup,
      'isActive': isActive,
      'lessonCount': lessonCount,
      'totalMinutes': totalMinutes,
      'createdAt': createdAt,
    };
    if (branchId != null) m['branchId'] = branchId;
    if (coverUrl != null) m['coverUrl'] = coverUrl;
    if (updatedAt != null) m['updatedAt'] = updatedAt;
    return m;
  }

  NurseryCourse copyWith({
    String? id,
    String? nurseryId,
    String? branchId,
    List<String>? branchIds,
    String? title,
    String? description,
    double? price,
    String? coverUrl,
    CourseCategory? category,
    String? ageGroup,
    bool? isActive,
    int? lessonCount,
    int? totalMinutes,
    int? createdAt,
    int? updatedAt,
  }) =>
      NurseryCourse(
        id: id ?? this.id,
        nurseryId: nurseryId ?? this.nurseryId,
        branchId: branchId ?? this.branchId,
        branchIds: branchIds ?? this.branchIds,
        title: title ?? this.title,
        description: description ?? this.description,
        price: price ?? this.price,
        coverUrl: coverUrl ?? this.coverUrl,
        category: category ?? this.category,
        ageGroup: ageGroup ?? this.ageGroup,
        isActive: isActive ?? this.isActive,
        lessonCount: lessonCount ?? this.lessonCount,
        totalMinutes: totalMinutes ?? this.totalMinutes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  String get formattedDuration {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (totalMinutes == 0) return '—';
    if (h == 0) return '$m د';
    if (m == 0) return '$h س';
    return '$h س $m د';
  }

  bool get isFree => price == 0;
  String get priceLabel => isFree ? 'مجاني' : '${price.toInt()} جنيه';

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static List<String> _parseStringList(dynamic v) {
    if (v is List) {
      return v.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    if (v is Map) {
      return v.values.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    return const [];
  }
}

// ─── Enrollment (local progress tracking) ────────────────────────────────────

class CourseEnrollment {
  final String courseId;
  final List<String> completedLessonIds;

  const CourseEnrollment({
    required this.courseId,
    this.completedLessonIds = const [],
  });

  double progressFor(NurseryCourse c) =>
      c.lessonCount == 0 ? 0 : completedLessonIds.length / c.lessonCount;

  int completedCount() => completedLessonIds.length;

  bool isCompleted(String lessonId) => completedLessonIds.contains(lessonId);

  CourseEnrollment withCompleted(String lessonId) {
    if (completedLessonIds.contains(lessonId)) return this;
    return CourseEnrollment(
      courseId: courseId,
      completedLessonIds: [...completedLessonIds, lessonId],
    );
  }

  factory CourseEnrollment.fromJson(Map<String, dynamic> json, {required String courseId}) {
    final ids = json['completedLessonIds'];
    List<String> list = [];
    if (ids is List) list = ids.map((e) => e.toString()).toList();
    if (ids is Map) list = ids.values.map((e) => e.toString()).toList();
    return CourseEnrollment(courseId: courseId, completedLessonIds: list);
  }

  Map<String, dynamic> toJson() => {
    'completedLessonIds': completedLessonIds,
    'savedAt': DateTime.now().millisecondsSinceEpoch,
  };
}
