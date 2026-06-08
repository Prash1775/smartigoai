import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../features/daily_quiz/models/daily_quiz.dart';
import '../features/daily_quiz/models/quiz_question.dart';
import '../features/daily_quiz/models/quiz_result.dart';
import '../features/learning_analytics/models/daily_report.dart';
import '../features/learning_analytics/models/flashcard.dart';
import '../features/learning_analytics/models/generated_note.dart';
import '../features/learning_analytics/models/learning_event.dart';
import '../features/learning_analytics/models/readiness_score.dart';
import '../features/learning_analytics/models/revision_task.dart';
import '../features/learning_analytics/models/vocabulary_entry.dart';
import '../features/learning_analytics/models/weekly_report.dart';
import '../features/sprint4/models/achievement.dart';
import '../features/sprint4/models/essay_evaluation.dart';
import '../features/sprint4/models/leaderboard_entry.dart';
import '../features/sprint4/models/mock_result.dart';
import '../features/sprint4/models/mock_test.dart';
import '../features/sprint4/models/score_prediction.dart';
import '../features/sprint4/models/speaking_evaluation.dart';
import '../features/sprint5/models/university.dart';
import '../features/sprint5/models/scholarship.dart';
import '../features/sprint5/models/interview_session.dart';
import '../features/sprint5/models/study_group.dart';
import '../features/sprint5/models/group_message.dart';
import '../features/sprint5/models/post.dart';
import '../features/sprint5/models/comment.dart';
import '../features/sprint5/models/subscription.dart';
import '../features/sprint5/models/payment.dart';
import '../features/sprint5/models/career_roadmap.dart';
import '../features/study_planner/models/daily_task.dart';
import '../features/study_planner/models/study_plan.dart';
import '../config/firebase_options.dart';

class FirestoreService {
  static bool get isFirebaseAvailable {
    try {
      final apiKey = DefaultFirebaseOptions.currentPlatform.apiKey;
      return !apiKey.contains('YOUR_') && apiKey.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
  static final Map<String, SmartGoUser> _mockUsers = {};
  static final _userStreams = <String, StreamController<SmartGoUser?>>{};

  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  static const String _usersCollection = 'users';
  static const String _studyPlansCollection = 'study_plans';
  static const String _dailyTasksCollection = 'daily_tasks';
  static const String _dailyQuizzesCollection = 'daily_quizzes';
  static const String _quizQuestionsCollection = 'quiz_questions';
  static const String _quizResultsCollection = 'quiz_results';
  static const String _learningEventsCollection = 'learning_events';
  static const String _dailyReportsCollection = 'daily_reports';
  static const String _weeklyReportsCollection = 'weekly_reports';
  static const String _readinessScoresCollection = 'readiness_scores';
  static const String _vocabularyCollection = 'vocabulary';
  static const String _flashcardsCollection = 'flashcards';
  static const String _generatedNotesCollection = 'generated_notes';
  static const String _revisionTasksCollection = 'revision_tasks';
  static const String _speakingEvaluationsCollection = 'speaking_evaluations';
  static const String _essayEvaluationsCollection = 'essay_evaluations';
  static const String _mockTestsCollection = 'mock_tests';
  static const String _mockResultsCollection = 'mock_results';
  static const String _predictionsCollection = 'predictions';
  static const String _achievementsCollection = 'achievements';
  static const String _leaderboardsCollection = 'leaderboards';
  static const String _universitiesCollection = 'universities';
  static const String _scholarshipsCollection = 'scholarships';
  static const String _interviewSessionsCollection = 'interview_sessions';
  static const String _studyGroupsCollection = 'study_groups';
  static const String _groupMessagesCollection = 'group_messages';
  static const String _forumPostsCollection = 'forum_posts';
  static const String _forumCommentsCollection = 'forum_comments';
  static const String _subscriptionsCollection = 'subscriptions';
  static const String _paymentsCollection = 'payments';
  static const String _careerRoadsCollection = 'career_roadmaps';

  /// Create or update user in Firestore
  static Future<void> createUser(SmartGoUser user) async {
    if (!isFirebaseAvailable) {
      _mockUsers[user.uid] = user;
      _userStreams[user.uid]?.add(user);
      return;
    }
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .set(user.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// Get user from Firestore
  static Future<SmartGoUser?> getUser(String uid) async {
    if (!isFirebaseAvailable) {
      return _mockUsers[uid];
    }
    try {
      final docSnapshot =
          await _firestore.collection(_usersCollection).doc(uid).get();

      if (docSnapshot.exists) {
        return SmartGoUser.fromMap(docSnapshot.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Get user stream for real-time updates
  static Stream<SmartGoUser?> getUserStream(String uid) {
    if (!isFirebaseAvailable) {
      final controller = _userStreams.putIfAbsent(uid, () => StreamController<SmartGoUser?>.broadcast());
      Future.microtask(() => controller.add(_mockUsers[uid]));
      return controller.stream;
    }
    try {
      return _firestore
          .collection(_usersCollection)
          .doc(uid)
          .snapshots()
          .map((snapshot) {
        if (snapshot.exists) {
          return SmartGoUser.fromMap(snapshot.data() as Map<String, dynamic>);
        }
        return null;
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Update user profile
  static Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    if (!isFirebaseAvailable) {
      final current = _mockUsers[uid];
      if (current != null) {
        final updated = current.copyWith(
          name: data['name'] as String?,
          email: data['email'] as String?,
          examType: data['examType'] as String?,
          targetScore: data['targetScore'] as int?,
          studyStreak: data['studyStreak'] as int?,
          readinessScore: (data['readinessScore'] as num?)?.toDouble(),
          isOnboarded: data['isOnboarded'] as bool?,
          currentLevel: data['currentLevel'] as String?,
          examDate: data['examDate'] as String?,
          weakAreas: (data['weakAreas'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList(),
          dailyStudyMinutes: (data['dailyStudyMinutes'] as num?)?.toInt(),
          studyPlan: data['studyPlan'] as Map<String, dynamic>?,
        );
        _mockUsers[uid] = updated;
        _userStreams[uid]?.add(updated);
      }
      return;
    }
    try {
      await _firestore.collection(_usersCollection).doc(uid).update(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update study streak
  static Future<void> updateStudyStreak(String uid, int streak) async {
    if (!isFirebaseAvailable) {
      final current = _mockUsers[uid];
      if (current != null) {
        final updated = current.copyWith(studyStreak: streak);
        _mockUsers[uid] = updated;
        _userStreams[uid]?.add(updated);
      }
      return;
    }
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .update({'studyStreak': streak});
    } catch (e) {
      rethrow;
    }
  }

  /// Update readiness score
  static Future<void> updateReadinessScore(String uid, double score) async {
    if (!isFirebaseAvailable) {
      final current = _mockUsers[uid];
      if (current != null) {
        final updated = current.copyWith(readinessScore: score);
        _mockUsers[uid] = updated;
        _userStreams[uid]?.add(updated);
      }
      return;
    }
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .update({'readinessScore': score});
    } catch (e) {
      rethrow;
    }
  }

  /// Update target score
  static Future<void> updateTargetScore(String uid, int targetScore) async {
    if (!isFirebaseAvailable) {
      final current = _mockUsers[uid];
      if (current != null) {
        final updated = current.copyWith(targetScore: targetScore);
        _mockUsers[uid] = updated;
        _userStreams[uid]?.add(updated);
      }
      return;
    }
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .update({'targetScore': targetScore});
    } catch (e) {
      rethrow;
    }
  }

  /// Create a study plan
  static Future<void> createStudyPlan(StudyPlan plan) async {
    if (!isFirebaseAvailable) return;
    try {
      await _firestore
          .collection(_studyPlansCollection)
          .doc(plan.id)
          .set(plan.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// Create daily tasks for a plan
  static Future<void> createDailyTasks(List<DailyTask> tasks) async {
    if (!isFirebaseAvailable) return;
    final batch = _firestore.batch();
    for (var task in tasks) {
      final doc = _firestore.collection(_dailyTasksCollection).doc(task.id);
      batch.set(doc, task.toMap());
    }
    try {
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  /// Create a daily quiz record
  static Future<void> createDailyQuiz(DailyQuiz quiz) async {
    if (!isFirebaseAvailable) return;
    try {
      await _firestore
          .collection(_dailyQuizzesCollection)
          .doc(quiz.id)
          .set(quiz.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// Create quiz questions for a generated quiz
  static Future<void> createQuizQuestions(List<QuizQuestion> questions) async {
    if (!isFirebaseAvailable) return;
    final batch = _firestore.batch();
    for (var question in questions) {
      final doc =
          _firestore.collection(_quizQuestionsCollection).doc(question.id);
      batch.set(doc, question.toMap());
    }
    try {
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  /// Create a quiz result document when the user submits answers
  static Future<void> createQuizResult(QuizResult result) async {
    if (!isFirebaseAvailable) return;
    try {
      await _firestore
          .collection(_quizResultsCollection)
          .doc(result.id)
          .set(result.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// Get study plans for a user
  static Stream<List<StudyPlan>> getStudyPlans(String uid) {
    if (!isFirebaseAvailable) return Stream.value([]);
    try {
      return _firestore
          .collection(_studyPlansCollection)
          .where('uid', isEqualTo: uid)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => StudyPlan.fromMap(doc.data()))
              .toList());
    } catch (e) {
      rethrow;
    }
  }

  /// Get daily tasks for a plan
  static Stream<List<DailyTask>> getDailyTasks(String planId) {
    if (!isFirebaseAvailable) return Stream.value([]);
    try {
      return _firestore
          .collection(_dailyTasksCollection)
          .where('planId', isEqualTo: planId)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => DailyTask.fromMap(doc.data()))
              .toList());
    } catch (e) {
      rethrow;
    }
  }

  /// Delete user
  static Future<void> deleteUser(String uid) async {
    if (!isFirebaseAvailable) {
      _mockUsers.remove(uid);
      _userStreams[uid]?.add(null);
      return;
    }
    try {
      await _firestore.collection(_usersCollection).doc(uid).delete();
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> createLearningEvent(LearningEvent event) async {
    if (!isFirebaseAvailable) return;
    await _firestore
        .collection(_learningEventsCollection)
        .doc(event.id)
        .set(event.toMap());
  }

  static Future<void> createDailyReport(DailyReport report) async {
    if (!isFirebaseAvailable) return;
    await _firestore
        .collection(_dailyReportsCollection)
        .doc(report.id)
        .set(report.toMap());
  }

  static Future<void> createWeeklyReport(WeeklyReport report) async {
    if (!isFirebaseAvailable) return;
    await _firestore
        .collection(_weeklyReportsCollection)
        .doc(report.id)
        .set(report.toMap());
  }

  static Future<void> createReadinessScore(ReadinessScore score) async {
    if (!isFirebaseAvailable) {
      await updateReadinessScore(score.uid, score.score);
      return;
    }
    await _firestore
        .collection(_readinessScoresCollection)
        .doc(score.id)
        .set(score.toMap());
    await updateReadinessScore(score.uid, score.score);
  }

  static Future<void> createVocabularyEntry(VocabularyEntry entry) async {
    if (!isFirebaseAvailable) return;
    await _firestore
        .collection(_vocabularyCollection)
        .doc(entry.id)
        .set(entry.toMap());
  }

  static Future<void> createFlashcard(Flashcard card) async {
    if (!isFirebaseAvailable) return;
    await _firestore
        .collection(_flashcardsCollection)
        .doc(card.id)
        .set(card.toMap());
  }

  static Future<void> createGeneratedNote(GeneratedNote note) async {
    if (!isFirebaseAvailable) return;
    await _firestore
        .collection(_generatedNotesCollection)
        .doc(note.id)
        .set(note.toMap());
  }

  static Future<void> createRevisionTask(RevisionTask task) async {
    if (!isFirebaseAvailable) return;
    await _firestore
        .collection(_revisionTasksCollection)
        .doc(task.id)
        .set(task.toMap());
  }

  static Stream<List<LearningEvent>> getLearningEvents(String uid) {
    if (!isFirebaseAvailable) return Stream.value([]);
    return _watchUserCollection(
      _learningEventsCollection,
      uid,
      LearningEvent.fromMap,
    );
  }

  static Stream<List<DailyReport>> getDailyReports(String uid) {
    if (!isFirebaseAvailable) return Stream.value([]);
    return _watchUserCollection(
        _dailyReportsCollection, uid, DailyReport.fromMap);
  }

  static Stream<List<WeeklyReport>> getWeeklyReports(String uid) {
    if (!isFirebaseAvailable) return Stream.value([]);
    return _watchUserCollection(
        _weeklyReportsCollection, uid, WeeklyReport.fromMap);
  }

  static Stream<List<ReadinessScore>> getReadinessScores(String uid) {
    if (!isFirebaseAvailable) return Stream.value([]);
    return _watchUserCollection(
        _readinessScoresCollection, uid, ReadinessScore.fromMap);
  }

  static Stream<List<VocabularyEntry>> getVocabulary(String uid) {
    if (!isFirebaseAvailable) return Stream.value([]);
    return _watchUserCollection(
        _vocabularyCollection, uid, VocabularyEntry.fromMap);
  }

  static Stream<List<Flashcard>> getFlashcards(String uid) {
    if (!isFirebaseAvailable) return Stream.value([]);
    return _watchUserCollection(_flashcardsCollection, uid, Flashcard.fromMap);
  }

  static Stream<List<GeneratedNote>> getGeneratedNotes(String uid) {
    if (!isFirebaseAvailable) return Stream.value([]);
    return _watchUserCollection(
        _generatedNotesCollection, uid, GeneratedNote.fromMap);
  }

  static Stream<List<RevisionTask>> getRevisionTasks(String uid) {
    if (!isFirebaseAvailable) return Stream.value([]);
    return _watchUserCollection(
        _revisionTasksCollection, uid, RevisionTask.fromMap);
  }

  static Future<void> createSpeakingEvaluation(
      SpeakingEvaluation evaluation) async {
    if (!isFirebaseAvailable) return;
    await _firestore
        .collection(_speakingEvaluationsCollection)
        .doc(evaluation.id)
        .set(evaluation.toMap());
  }

  static Future<void> createEssayEvaluation(EssayEvaluation evaluation) async {
    if (!isFirebaseAvailable) return;
    await _firestore
        .collection(_essayEvaluationsCollection)
        .doc(evaluation.id)
        .set(evaluation.toMap());
  }

  static Future<void> createMockTest(MockTest test) async {
    if (!isFirebaseAvailable) return;
    await _firestore
        .collection(_mockTestsCollection)
        .doc(test.id)
        .set(test.toMap());
  }

  static Future<void> createMockResult(MockResult result) async {
    if (!isFirebaseAvailable) return;
    await _firestore
        .collection(_mockResultsCollection)
        .doc(result.id)
        .set(result.toMap());
  }

  static Future<void> createScorePrediction(ScorePrediction prediction) async {
    if (!isFirebaseAvailable) return;
    await _firestore
        .collection(_predictionsCollection)
        .doc(prediction.id)
        .set(prediction.toMap());
  }

  static Future<void> createAchievement(Achievement achievement) async {
    if (!isFirebaseAvailable) return;
    await _firestore
        .collection(_achievementsCollection)
        .doc(achievement.id)
        .set(achievement.toMap(), SetOptions(merge: true));
  }

  static Future<void> upsertLeaderboardEntry(LeaderboardEntry entry) async {
    if (!isFirebaseAvailable) return;
    final doc = _firestore.collection(_leaderboardsCollection).doc(entry.uid);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(doc);
      if (!snapshot.exists) {
        transaction.set(doc, entry.toMap());
        return;
      }
      final current =
          LeaderboardEntry.fromMap(snapshot.data() as Map<String, dynamic>);
      transaction.update(doc, {
        'points': current.points + entry.points,
        'mockTestsCompleted':
            current.mockTestsCompleted + entry.mockTestsCompleted,
        'displayName': entry.displayName,
        'examType': entry.examType,
        'updatedAt': Timestamp.fromDate(entry.updatedAt),
      });
    });
  }

  static Stream<List<Achievement>> getAchievements(String uid) {
    if (!isFirebaseAvailable) return Stream.value([]);
    return _watchUserCollection(
        _achievementsCollection, uid, Achievement.fromMap);
  }

  static Stream<List<University>> getUniversities() {
    if (!isFirebaseAvailable) return Stream.value([]);
    return _firestore
        .collection(_universitiesCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => University.fromMap(doc.data()))
            .toList());
  }

  static Future<List<University>> searchUniversities(
    String query, {
    String? country,
    int? maxRanking,
  }) async {
    if (!isFirebaseAvailable) return [];
    Query q = _firestore.collection(_universitiesCollection);
    if (country != null && country.isNotEmpty) {
      q = q.where('country', isEqualTo: country);
    }
    if (maxRanking != null) {
      q = q.where('ranking', isLessThanOrEqualTo: maxRanking);
    }
    final snapshot = await q.get();
    final universities = snapshot.docs
        .map((doc) => University.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
    if (query.isEmpty) {
      return universities;
    }
    final lowerQuery = query.toLowerCase();
    return universities.where((uni) {
      return uni.name.toLowerCase().contains(lowerQuery) ||
          uni.programs.any((prog) => prog.toLowerCase().contains(lowerQuery)) ||
          uni.city.toLowerCase().contains(lowerQuery) ||
          uni.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  static Stream<List<Scholarship>> getScholarships() {
    if (!isFirebaseAvailable) return Stream.value([]);
    return _firestore
        .collection(_scholarshipsCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Scholarship.fromMap(doc.data()))
            .toList());
  }

  static Future<List<Scholarship>> searchScholarships(
    String query, {
    String? universityId,
  }) async {
    if (!isFirebaseAvailable) return [];
    Query q = _firestore.collection(_scholarshipsCollection);
    if (universityId != null && universityId.isNotEmpty) {
      q = q.where('universityId', isEqualTo: universityId);
    }
    final snapshot = await q.get();
    final scholarships = snapshot.docs
        .map((doc) => Scholarship.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
    if (query.isEmpty) {
      return scholarships;
    }
    final lowerQuery = query.toLowerCase();
    return scholarships.where((s) {
      return s.name.toLowerCase().contains(lowerQuery) ||
          s.universityName.toLowerCase().contains(lowerQuery) ||
          s.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  static Future<void> createInterviewSession(InterviewSession session) async {
    if (!isFirebaseAvailable) return;
    await _firestore
        .collection(_interviewSessionsCollection)
        .doc(session.id)
        .set(session.toMap());
  }

  static Stream<List<InterviewSession>> getInterviewSessions(String uid) {
    if (!isFirebaseAvailable) return Stream.value([]);
    return _watchUserCollection(
      _interviewSessionsCollection,
      uid,
      InterviewSession.fromMap,
    );
  }

  static Future<void> createStudyGroup(StudyGroup group) async {
    if (!isFirebaseAvailable) return;
    await _firestore
        .collection(_studyGroupsCollection)
        .doc(group.id)
        .set(group.toMap());
  }

  static Future<void> joinStudyGroup(String groupId, String uid) async {
    if (!isFirebaseAvailable) return;
    await _firestore.collection(_studyGroupsCollection).doc(groupId).update({
      'memberUids': FieldValue.arrayUnion([uid]),
      'memberCount': FieldValue.increment(1),
    });
  }

  static Stream<List<StudyGroup>> getStudyGroups() {
    if (!isFirebaseAvailable) return Stream.value([]);
    return _firestore
        .collection(_studyGroupsCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StudyGroup.fromMap(doc.data()))
            .toList());
  }

  static Future<void> createGroupMessage(GroupMessage msg) async {
    if (!isFirebaseAvailable) return;
    final batch = _firestore.batch();
    final messageDoc = _firestore.collection(_groupMessagesCollection).doc(msg.id);
    batch.set(messageDoc, msg.toMap());
    final groupDoc = _firestore.collection(_studyGroupsCollection).doc(msg.groupId);
    batch.update(groupDoc, {
      'messageCount': FieldValue.increment(1),
    });
    await batch.commit();
  }

  static Stream<List<GroupMessage>> getGroupMessages(String groupId) {
    if (!isFirebaseAvailable) return Stream.value([]);
    return _firestore
        .collection(_groupMessagesCollection)
        .where('groupId', isEqualTo: groupId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GroupMessage.fromMap(doc.data()))
            .toList());
  }

  static Future<void> createPost(Post post) async {
    if (!isFirebaseAvailable) return;
    await _firestore
        .collection(_forumPostsCollection)
        .doc(post.id)
        .set(post.toMap());
  }

  static Stream<List<Post>> getPosts() {
    if (!isFirebaseAvailable) return Stream.value([]);
    return _firestore
        .collection(_forumPostsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Post.fromMap(doc.data())).toList());
  }

  static Future<void> upvotePost(String postId) async {
    if (!isFirebaseAvailable) return;
    await _firestore.collection(_forumPostsCollection).doc(postId).update({
      'upvotes': FieldValue.increment(1),
    });
  }

  static Future<void> createComment(Comment comment) async {
    if (!isFirebaseAvailable) return;
    final batch = _firestore.batch();
    final commentDoc = _firestore.collection(_forumCommentsCollection).doc(comment.id);
    batch.set(commentDoc, comment.toMap());
    final postDoc = _firestore.collection(_forumPostsCollection).doc(comment.postId);
    batch.update(postDoc, {
      'commentCount': FieldValue.increment(1),
    });
    await batch.commit();
  }

  static Stream<List<Comment>> getComments(String postId) {
    if (!isFirebaseAvailable) return Stream.value([]);
    return _firestore
        .collection(_forumCommentsCollection)
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Comment.fromMap(doc.data()))
            .toList());
  }

  static Future<void> createSubscription(Subscription subscription) async {
    if (!isFirebaseAvailable) return;
    await _firestore
        .collection(_subscriptionsCollection)
        .doc(subscription.uid)
        .set(subscription.toMap());
  }

  static Stream<Subscription?> getSubscription(String uid) {
    if (!isFirebaseAvailable) return Stream.value(null);
    return _firestore
        .collection(_subscriptionsCollection)
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return Subscription.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  static Future<void> createPayment(Payment payment) async {
    if (!isFirebaseAvailable) return;
    await _firestore
        .collection(_paymentsCollection)
        .doc(payment.id)
        .set(payment.toMap());
  }

  static Future<void> createCareerRoadmap(CareerRoadmap roadmap) async {
    if (!isFirebaseAvailable) return;
    await _firestore
        .collection(_careerRoadsCollection)
        .doc(roadmap.uid)
        .set(roadmap.toMap());
  }

  static Stream<CareerRoadmap?> getCareerRoadmap(String uid) {
    if (!isFirebaseAvailable) return Stream.value(null);
    return _firestore
        .collection(_careerRoadsCollection)
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return CareerRoadmap.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  static Stream<List<LeaderboardEntry>> getLeaderboard() {
    if (!isFirebaseAvailable) return Stream.value([]);
    return _firestore
        .collection(_leaderboardsCollection)
        .orderBy('points', descending: true)
        .limit(25)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LeaderboardEntry.fromMap(doc.data()))
            .toList());
  }

  static Stream<List<T>> _watchUserCollection<T>(
    String collection,
    String uid,
    T Function(Map<String, dynamic>) fromMap,
  ) {
    return _firestore
        .collection(collection)
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => fromMap(doc.data())).toList());
  }
}
