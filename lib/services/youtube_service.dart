import 'dart:convert';
import 'package:http/http.dart' as http;

class YouTubeVideo {
  final String videoId;
  final String title;
  final String channelTitle;
  final String thumbnailUrl;
  final String description;

  const YouTubeVideo({
    required this.videoId,
    required this.title,
    required this.channelTitle,
    required this.thumbnailUrl,
    required this.description,
  });

  String get watchUrl => 'https://www.youtube.com/watch?v=$videoId';
  String get embedUrl => 'https://www.youtube.com/embed/$videoId';

  factory YouTubeVideo.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet'] as Map<String, dynamic>;
    final thumbnails = snippet['thumbnails'] as Map<String, dynamic>;
    final thumbnailUrl = (thumbnails['high'] ?? thumbnails['medium'] ?? thumbnails['default'])
        as Map<String, dynamic>;

    return YouTubeVideo(
      videoId: (json['id'] as Map<String, dynamic>)['videoId'] as String,
      title: snippet['title'] as String,
      channelTitle: snippet['channelTitle'] as String,
      thumbnailUrl: thumbnailUrl['url'] as String,
      description: snippet['description'] as String? ?? '',
    );
  }
}

class YouTubeService {
  // YouTube Data API v3 key – replace with your key
  // Get a free key at: https://console.cloud.google.com/apis/library/youtube.googleapis.com
  static String get _apiKey =>
      const String.fromEnvironment('YOUTUBE_API_KEY',
          defaultValue: );

  static const _baseUrl = 'https://www.googleapis.com/youtube/v3/search';

  /// Fetch exam-specific educational videos for the student
  static Future<List<YouTubeVideo>> fetchVideosForExam({
    required String examType,
    String? topic,
    int maxResults = 6,
  }) async {
    // Build a targeted search query strictly for the student's exam
    final searchQuery = topic != null && topic.isNotEmpty
        ? '$examType $topic tutorial tips'
        : '$examType exam preparation tips strategies 2025';

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'part': 'snippet',
      'q': searchQuery,
      'maxResults': maxResults.toString(),
      'type': 'video',
      'key': _apiKey,
      'videoEmbeddable': 'true',
    });

    return _executeRequest(uri);
  }

  /// Search YouTube videos with a raw custom query
  static Future<List<YouTubeVideo>> searchVideos(String query, {int maxResults = 5}) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'part': 'snippet',
      'q': query,
      'maxResults': maxResults.toString(),
      'type': 'video',
      'key': _apiKey,
      'videoEmbeddable': 'true',
    });

    return _executeRequest(uri);
  }

  static Future<List<YouTubeVideo>> _executeRequest(Uri uri) async {
    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        throw Exception('YouTube API error: ${response.statusCode}');
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];
      
      return items.map((item) => YouTubeVideo.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to fetch videos: $e');
    }
  }
}
