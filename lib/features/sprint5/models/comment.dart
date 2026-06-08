import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId;
  final String authorUid;
  final String authorName;
  final String content;
  final int upvotes;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.authorUid,
    required this.authorName,
    required this.content,
    required this.upvotes,
    required this.createdAt,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] as String,
      postId: map['postId'] as String,
      authorUid: map['authorUid'] as String,
      authorName: map['authorName'] as String,
      content: map['content'] as String,
      upvotes: (map['upvotes'] as num).toInt(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'authorUid': authorUid,
      'authorName': authorName,
      'content': content,
      'upvotes': upvotes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
