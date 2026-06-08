import 'package:cloud_firestore/cloud_firestore.dart';

class University {
  final String id;
  final String name;
  final String country;
  final String city;
  final List<String> programs;
  final double avgGREScore;
  final double avgGMATScore;
  final double avgIELTSScore;
  final double acceptanceRate;
  final int ranking;
  final String website;
  final String description;
  final DateTime createdAt;

  University({
    required this.id,
    required this.name,
    required this.country,
    required this.city,
    required this.programs,
    required this.avgGREScore,
    required this.avgGMATScore,
    required this.avgIELTSScore,
    required this.acceptanceRate,
    required this.ranking,
    required this.website,
    required this.description,
    required this.createdAt,
  });

  factory University.fromMap(Map<String, dynamic> map) {
    return University(
      id: map['id'] as String,
      name: map['name'] as String,
      country: map['country'] as String,
      city: map['city'] as String,
      programs: List<String>.from(map['programs'] as List),
      avgGREScore: (map['avgGREScore'] as num).toDouble(),
      avgGMATScore: (map['avgGMATScore'] as num).toDouble(),
      avgIELTSScore: (map['avgIELTSScore'] as num).toDouble(),
      acceptanceRate: (map['acceptanceRate'] as num).toDouble(),
      ranking: (map['ranking'] as num).toInt(),
      website: map['website'] as String,
      description: map['description'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'city': city,
      'programs': programs,
      'avgGREScore': avgGREScore,
      'avgGMATScore': avgGMATScore,
      'avgIELTSScore': avgIELTSScore,
      'acceptanceRate': acceptanceRate,
      'ranking': ranking,
      'website': website,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
