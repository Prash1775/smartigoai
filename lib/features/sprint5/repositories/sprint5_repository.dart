import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../services/firestore_service.dart';
import '../../../services/gemini_service.dart';
import '../models/career_roadmap.dart';
import '../models/comment.dart';
import '../models/group_message.dart';
import '../models/interview_session.dart';
import '../models/payment.dart';
import '../models/post.dart';
import '../models/scholarship.dart';
import '../models/study_group.dart';
import '../models/subscription.dart';
import '../models/university.dart';

class Sprint5Repository {
  final GeminiService _geminiService;

  Sprint5Repository({GeminiService? geminiService})
      : _geminiService = geminiService ?? GeminiService();

  // ==================== University Finder ====================
  Stream<List<University>> watchUniversities() {
    try {
      return FirestoreService.getUniversities().handleError((err) {
        debugPrint('Firestore universities error, using mock data: $err');
        return _mockUniversities;
      });
    } catch (e) {
      debugPrint('Firestore universities stream error, using mock: $e');
      return Stream.value(_mockUniversities);
    }
  }

  Future<List<University>> searchUniversities(
    String query, {
    String? country,
    int? maxRanking,
  }) async {
    try {
      return await FirestoreService.searchUniversities(query,
          country: country, maxRanking: maxRanking);
    } catch (_) {
      final lowerQuery = query.toLowerCase();
      return _mockUniversities.where((uni) {
        final matchesQuery = query.isEmpty ||
            uni.name.toLowerCase().contains(lowerQuery) ||
            uni.programs.any((prog) => prog.toLowerCase().contains(lowerQuery)) ||
            uni.city.toLowerCase().contains(lowerQuery) ||
            uni.description.toLowerCase().contains(lowerQuery);
        final matchesCountry = country == null || country.isEmpty || uni.country == country;
        final matchesRanking = maxRanking == null || uni.ranking <= maxRanking;
        return matchesQuery && matchesCountry && matchesRanking;
      }).toList();
    }
  }

  // ==================== Scholarship Finder ====================
  Stream<List<Scholarship>> watchScholarships() {
    try {
      return FirestoreService.getScholarships().handleError((err) {
        debugPrint('Firestore scholarships error, using mock data: $err');
        return _mockScholarships;
      });
    } catch (e) {
      debugPrint('Firestore scholarships stream error, using mock: $e');
      return Stream.value(_mockScholarships);
    }
  }

  Future<List<Scholarship>> searchScholarships(
    String query, {
    String? universityId,
  }) async {
    try {
      return await FirestoreService.searchScholarships(query,
          universityId: universityId);
    } catch (_) {
      final lowerQuery = query.toLowerCase();
      return _mockScholarships.where((s) {
        final matchesQuery = query.isEmpty ||
            s.name.toLowerCase().contains(lowerQuery) ||
            s.universityName.toLowerCase().contains(lowerQuery) ||
            s.description.toLowerCase().contains(lowerQuery);
        final matchesUni = universityId == null || universityId == 'any' || s.universityId == universityId;
        return matchesQuery && matchesUni;
      }).toList();
    }
  }

  // ==================== Interview Coach ====================
  Future<InterviewSession> conductInterviewSession({
    required String uid,
    required String displayName,
    required String topic,
    required String userAnswer,
  }) async {
    final question = _generateInterviewQuestion(topic);
    final aiFeedback = await _safeGenerate(
      '''You are an expert interview coach. Evaluate this interview response.

Topic: $topic
Question: $question
Candidate Answer: $userAnswer

Provide:
1. Overall assessment (1 sentence)
2. Three specific improvements
Format: assessment|||improvement1|||improvement2|||improvement3''',
    );

    final parts = aiFeedback?.split('|||') ?? [];
    final feedback = parts.isNotEmpty ? parts[0] : 'Strong response. Focus on specificity and examples.';
    final improvements = parts.length > 3
        ? parts.sublist(1, 4)
        : [
            'Use concrete examples.',
            'Enhance clarity and structure.',
            'Build confidence in delivery.'
          ];

    final session = InterviewSession(
      id: '${uid}_interview_${DateTime.now().millisecondsSinceEpoch}',
      uid: uid,
      displayName: displayName,
      topic: topic,
      question: question,
      userAnswer: userAnswer,
      aiEvaluation: feedback,
      confidenceScore: _estimateScore(userAnswer, 7.5),
      clarityScore: _estimateScore(userAnswer, 7.0),
      structureScore: _estimateScore(userAnswer, 7.2),
      overallScore: _estimateScore(userAnswer, 7.2),
      improvements: improvements,
      createdAt: DateTime.now(),
    );

    try {
      await FirestoreService.createInterviewSession(session);
    } catch (e) {
      debugPrint('Skipped Firestore save for interview session: $e');
    }
    return session;
  }

  Stream<List<InterviewSession>> watchInterviewSessions(String uid) {
    try {
      return FirestoreService.getInterviewSessions(uid).handleError((err) {
        return <InterviewSession>[];
      });
    } catch (_) {
      return Stream.value(<InterviewSession>[]);
    }
  }

  // ==================== Study Groups ====================
  Future<StudyGroup> createStudyGroup({
    required String uid,
    required String displayName,
    required String name,
    required String description,
    required String topic,
    required String examType,
  }) async {
    final group = StudyGroup(
      id: '${uid}_group_${DateTime.now().millisecondsSinceEpoch}',
      creatorUid: uid,
      creatorName: displayName,
      name: name,
      description: description,
      topic: topic,
      examType: examType,
      memberCount: 1,
      memberUids: [uid],
      visibility: 'Public',
      messageCount: 0,
      createdAt: DateTime.now(),
    );

    try {
      await FirestoreService.createStudyGroup(group);
    } catch (e) {
      debugPrint('Skipped Firestore save for study group: $e');
    }
    return group;
  }

  Future<void> joinStudyGroup(String groupId, String uid) async {
    try {
      await FirestoreService.joinStudyGroup(groupId, uid);
    } catch (e) {
      debugPrint('Skipped Firestore join study group: $e');
    }
  }

  Stream<List<StudyGroup>> watchStudyGroups() {
    try {
      return FirestoreService.getStudyGroups().handleError((err) {
        debugPrint('Firestore study groups error, using mock data: $err');
        return _mockStudyGroups;
      });
    } catch (e) {
      debugPrint('Firestore study groups stream error, using mock: $e');
      return Stream.value(_mockStudyGroups);
    }
  }

  Future<void> sendGroupMessage({
    required String groupId,
    required String uid,
    required String displayName,
    required String message,
  }) async {
    final msg = GroupMessage(
      id: '${groupId}_msg_${DateTime.now().millisecondsSinceEpoch}',
      groupId: groupId,
      senderUid: uid,
      senderName: displayName,
      message: message,
      createdAt: DateTime.now(),
    );

    try {
      await FirestoreService.createGroupMessage(msg);
    } catch (e) {
      debugPrint('Skipped Firestore save group message: $e');
    }
  }

  Stream<List<GroupMessage>> watchGroupMessages(String groupId) {
    try {
      return FirestoreService.getGroupMessages(groupId).handleError((err) {
        return <GroupMessage>[];
      });
    } catch (_) {
      return Stream.value(<GroupMessage>[]);
    }
  }

  // ==================== Community Forum ====================
  Future<Post> createPost({
    required String uid,
    required String displayName,
    required String title,
    required String content,
    required String category,
  }) async {
    final post = Post(
      id: '${uid}_post_${DateTime.now().millisecondsSinceEpoch}',
      authorUid: uid,
      authorName: displayName,
      title: title,
      content: content,
      category: category,
      upvotes: 0,
      commentCount: 0,
      createdAt: DateTime.now(),
    );

    try {
      await FirestoreService.createPost(post);
    } catch (e) {
      debugPrint('Skipped Firestore save post: $e');
    }
    return post;
  }

  Stream<List<Post>> watchPosts() {
    try {
      return FirestoreService.getPosts().handleError((err) {
        debugPrint('Firestore posts error, using mock data: $err');
        return _mockPosts;
      });
    } catch (e) {
      debugPrint('Firestore posts stream error, using mock: $e');
      return Stream.value(_mockPosts);
    }
  }

  Future<void> upvotePost(String postId) async {
    try {
      await FirestoreService.upvotePost(postId);
    } catch (e) {
      debugPrint('Skipped Firestore upvote post: $e');
    }
  }

  Future<Comment> createComment({
    required String postId,
    required String uid,
    required String displayName,
    required String content,
  }) async {
    final comment = Comment(
      id: '${postId}_comment_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      authorUid: uid,
      authorName: displayName,
      content: content,
      upvotes: 0,
      createdAt: DateTime.now(),
    );

    try {
      await FirestoreService.createComment(comment);
    } catch (e) {
      debugPrint('Skipped Firestore save comment: $e');
    }
    return comment;
  }

  Stream<List<Comment>> watchComments(String postId) {
    try {
      return FirestoreService.getComments(postId).handleError((err) {
        return <Comment>[];
      });
    } catch (_) {
      return Stream.value(<Comment>[]);
    }
  }

  // ==================== Premium Subscription ====================
  Future<void> upgradeToPremium({
    required String uid,
    required String plan,
  }) async {
    final monthlyPrice = plan == 'Pro' ? 9.99 : 19.99;
    final features = plan == 'Pro'
        ? [
            'Unlimited Mock Tests',
            'AI Interview Coach',
            'Study Groups',
            'Forum Access',
          ]
        : [
            'Everything in Pro',
            'Career Roadmap',
            'University Finder',
            'Scholarship Alerts',
            'Priority Support',
          ];

    final subscription = Subscription(
      id: '${uid}_sub_${DateTime.now().millisecondsSinceEpoch}',
      uid: uid,
      plan: plan,
      monthlyPrice: monthlyPrice,
      status: 'Active',
      startDate: DateTime.now(),
      expiryDate: DateTime.now().add(const Duration(days: 30)),
      features: features,
      autoRenew: true,
    );

    try {
      await FirestoreService.createSubscription(subscription);
    } catch (e) {
      debugPrint('Skipped Firestore save subscription: $e');
    }
  }

  Stream<Subscription?> watchSubscription(String uid) {
    try {
      return FirestoreService.getSubscription(uid).handleError((err) {
        return null;
      });
    } catch (_) {
      return Stream.value(null);
    }
  }

  Future<void> recordPayment({
    required String uid,
    required String subscriptionId,
    required double amount,
    required String paymentMethod,
  }) async {
    final payment = Payment(
      id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      uid: uid,
      subscriptionId: subscriptionId,
      amount: amount,
      currency: 'USD',
      status: 'Completed',
      paymentMethod: paymentMethod,
      transactionId: 'stripe_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );

    try {
      await FirestoreService.createPayment(payment);
    } catch (e) {
      debugPrint('Skipped Firestore save payment: $e');
    }
  }

  // ==================== Career Roadmap ====================
  Future<CareerRoadmap> generateCareerRoadmap({
    required String uid,
    required String careerGoal,
    required String targetRole,
    required String examType,
    required int targetScore,
  }) async {
    final prompt = '''You are a career advisor. Create a detailed career roadmap.

Career Goal: $careerGoal
Target Role: $targetRole
Exam Type: $examType
Target Score: $targetScore

Provide:
1. 5 milestones to reach the goal
2. 6 key skills to acquire
3. Top 3 recommended universities

Format each section separated by ||| 
Milestones: milestone1;milestone2;...
Skills: skill1;skill2;...
Universities: uni1;uni2;uni3
Guidance: A 2-sentence personalized plan''';

    final response = await _safeGenerate(prompt);
    final parts = response?.split('|||') ?? [];

    final milestonesStr = parts.isNotEmpty
        ? parts[0].replaceFirst('Milestones:', '').trim()
        : '';
    final skillsStr =
        parts.length > 1 ? parts[1].replaceFirst('Skills:', '').trim() : '';
    final unisStr =
        parts.length > 2 ? parts[2].replaceFirst('Universities:', '').trim() : '';
    final guidanceStr = parts.length > 3
        ? parts[3].replaceFirst('Guidance:', '').trim()
        : 'Focus on consistent study and practical experience.';

    final roadmap = CareerRoadmap(
      id: '${uid}_roadmap_${DateTime.now().millisecondsSinceEpoch}',
      uid: uid,
      careerGoal: careerGoal,
      targetRole: targetRole,
      examType: examType,
      targetScore: targetScore,
      milestones: milestonesStr.split(';').where((m) => m.isNotEmpty).toList(),
      skillsToAcquire: skillsStr.split(';').where((s) => s.isNotEmpty).toList(),
      recommendedUniversities:
          unisStr.split(';').where((u) => u.isNotEmpty).toList(),
      aiGuidance: guidanceStr,
      progressPercent: 0.0,
      createdAt: DateTime.now(),
      targetDate: DateTime.now().add(const Duration(days: 365)),
    );

    try {
      await FirestoreService.createCareerRoadmap(roadmap);
    } catch (e) {
      debugPrint('Skipped Firestore save roadmap: $e');
    }
    return roadmap;
  }

  Stream<CareerRoadmap?> watchCareerRoadmap(String uid) {
    try {
      return FirestoreService.getCareerRoadmap(uid).handleError((err) {
        return null;
      });
    } catch (_) {
      return Stream.value(null);
    }
  }

  // ==================== Helpers ====================
  String _generateInterviewQuestion(String topic) {
    final questions = {
      'Leadership': 'Describe a time when you led a team. What was the challenge and how did you overcome it?',
      'Problem Solving':
          'Tell me about a complex problem you solved. Walk me through your approach.',
      'Communication':
          'Give an example of when you had to explain a complex idea clearly to others.',
      'Teamwork':
          'Describe a situation where you had to collaborate with a difficult team member.',
      'Motivation': 'What drives you professionally? Why do you want this role?',
    };

    return questions[topic] ??
        'Can you tell me about yourself and your professional journey?';
  }

  double _estimateScore(String answer, double base) {
    final length = answer.trim().split(' ').length;
    if (length >= 150) return base + 0.5;
    if (length >= 100) return base;
    if (length >= 50) return base - 0.5;
    return base - 1.0;
  }

  Future<String?> _safeGenerate(String prompt) async {
    try {
      return await _geminiService.generateFromPrompt(
        prompt,
        temperature: 0.6,
        maxTokens: 500,
      );
    } catch (_) {
      return null;
    }
  }
}

// ==================== Mock Data ====================
final List<University> _mockUniversities = [
  University(
    id: 'uni_mit',
    name: 'Massachusetts Institute of Technology (MIT)',
    country: 'United States',
    city: 'Cambridge',
    programs: ['Computer Science', 'Data Science', 'Engineering', 'MBA'],
    avgGREScore: 325.0,
    avgGMATScore: 730.0,
    avgIELTSScore: 7.5,
    acceptanceRate: 7.3,
    ranking: 1,
    website: 'https://mit.edu',
    description: 'A world-class research university known for its focus on science, technology, and innovation.',
    createdAt: DateTime.now(),
  ),
  University(
    id: 'uni_oxford',
    name: 'University of Oxford',
    country: 'United Kingdom',
    city: 'Oxford',
    programs: ['Computer Science', 'Artificial Intelligence', 'Mathematics', 'Finance'],
    avgGREScore: 322.0,
    avgGMATScore: 710.0,
    avgIELTSScore: 7.5,
    acceptanceRate: 15.0,
    ranking: 3,
    website: 'https://ox.ac.uk',
    description: 'The oldest university in the English-speaking world, offering outstanding academic programs.',
    createdAt: DateTime.now(),
  ),
  University(
    id: 'uni_stanford',
    name: 'Stanford University',
    country: 'United States',
    city: 'Stanford',
    programs: ['Computer Science', 'Data Science', 'MBA', 'Electrical Engineering'],
    avgGREScore: 326.0,
    avgGMATScore: 737.0,
    avgIELTSScore: 7.5,
    acceptanceRate: 4.4,
    ranking: 2,
    website: 'https://stanford.edu',
    description: 'Located in Silicon Valley, Stanford is famous for its entrepreneurial spirit and academic excellence.',
    createdAt: DateTime.now(),
  ),
];

final List<Scholarship> _mockScholarships = [
  Scholarship(
    id: 'schol_1',
    name: 'Fulbright Foreign Student Program',
    universityId: 'any',
    universityName: 'Multiple US Universities',
    amount: 50000.0,
    currency: 'USD',
    deadline: 'October 15, 2026',
    eligibility: ['International students', 'Bachelor degree completed', 'English proficiency'],
    description: 'Covers tuition, airfare, a living stipend, and health insurance for graduate study in the US.',
    applicationUrl: 'https://foreign.fulbrightonline.org/',
    createdAt: DateTime.now(),
  ),
  Scholarship(
    id: 'schol_2',
    name: 'Rhodes Scholarship',
    universityId: 'uni_oxford',
    universityName: 'University of Oxford',
    amount: 65000.0,
    currency: 'GBP',
    deadline: 'October 1, 2026',
    eligibility: ['Exceptional academic record', 'Leadership potential', 'Ages 18-24'],
    description: 'One of the most prestigious international scholarships, covering all expenses at Oxford.',
    applicationUrl: 'https://www.rhodeshouse.ox.ac.uk/',
    createdAt: DateTime.now(),
  ),
];

final List<StudyGroup> _mockStudyGroups = [
  StudyGroup(
    id: 'group_1',
    creatorUid: 'admin',
    creatorName: 'SmartGo Advisor',
    name: 'IELTS Band 8+ Achievers',
    description: 'A study group dedicated to sharing advanced IELTS tips, essays, and speaking practice.',
    topic: 'Speaking',
    examType: 'IELTS',
    memberCount: 15,
    memberUids: ['admin'],
    visibility: 'Public',
    messageCount: 42,
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
  ),
  StudyGroup(
    id: 'group_2',
    creatorUid: 'admin',
    creatorName: 'SmartGo Advisor',
    name: 'GRE Quantitative Prep',
    description: 'Focusing on tough math sections, data sufficiency, and coordinate geometry questions.',
    topic: 'Vocabulary',
    examType: 'GRE',
    memberCount: 8,
    memberUids: ['admin'],
    visibility: 'Public',
    messageCount: 12,
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
];

final List<Post> _mockPosts = [
  Post(
    id: 'post_1',
    authorUid: 'admin',
    authorName: 'SmartGo Advisor',
    title: 'How I scored 330 on the GRE',
    content: 'Consistency is key. Focus heavily on official ETS prep materials and vocab retention lists daily.',
    category: 'Study Tips',
    upvotes: 24,
    commentCount: 5,
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  Post(
    id: 'post_2',
    authorUid: 'user_x',
    authorName: 'Sarah Jenkins',
    title: 'Need help with IELTS Task 2 essays',
    content: 'Any advice on structuring writing tasks for complex topics? I seem to struggle with coherence.',
    category: 'Exam Strategy',
    upvotes: 11,
    commentCount: 2,
    createdAt: DateTime.now().subtract(const Duration(hours: 12)),
  ),
];
