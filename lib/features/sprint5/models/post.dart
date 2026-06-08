import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String authorUid;
  final String authorName;
  final String title;
  final String content;
  final String category;
  final int upvotes;
  final int commentCount;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.authorUid,
    required this.authorName,
    required this.title,
    required this.content,
    required this.category,
    required this.upvotes,
    required this.commentCount,
    required this.createdAt,
  });

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] as String,
      authorUid: map['authorUid'] as String,
      authorName: map['authorName'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      category: map['category'] as String,
      upvotes: (map['upvotes'] as num).toInt(),
      commentCount: (map['commentCount'] as num).toInt(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorUid': authorUid,
      'authorName': authorName,
      'title': title,
      'content': content,
      'category': category,
      'upvotes': upvotes,
      'commentCount': commentCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
