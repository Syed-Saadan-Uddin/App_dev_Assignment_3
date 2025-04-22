import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String content;
  
  @HiveField(3)
  final String category;
  
  @HiveField(4)
  final DateTime createdAt;
  
  @HiveField(5)
  final bool isPinned;
  
  @HiveField(6)
  final List<String> imagePaths;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.createdAt,
    this.isPinned = false,
    this.imagePaths = const [],
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    DateTime? createdAt,
    bool? isPinned,
    List<String>? imagePaths,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isPinned: isPinned ?? this.isPinned,
      imagePaths: imagePaths ?? this.imagePaths,
    );
  }
}