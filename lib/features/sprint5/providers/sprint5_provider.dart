import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/exam_types.dart';
import '../models/career_roadmap.dart';
import '../models/comment.dart';
import '../models/group_message.dart';
import '../models/interview_session.dart';
import '../models/post.dart';
import '../models/scholarship.dart';
import '../models/study_group.dart';
import '../models/subscription.dart';
import '../models/university.dart';
import '../repositories/sprint5_repository.dart';

final sprint5RepositoryProvider = Provider<Sprint5Repository>((ref) {
  return Sprint5Repository();
});

final sprint5Provider =
    StateNotifierProvider<Sprint5Notifier, Sprint5State>((ref) {
  return Sprint5Notifier(ref.watch(sprint5RepositoryProvider));
});

// University Finder Streams
final universitiesProvider = StreamProvider<List<University>>((ref) {
  return ref.watch(sprint5RepositoryProvider).watchUniversities();
});

// Scholarship Finder Streams
final scholarshipsProvider = StreamProvider<List<Scholarship>>((ref) {
  return ref.watch(sprint5RepositoryProvider).watchScholarships();
});

// Interview Sessions Streams
final interviewSessionsProvider =
    StreamProvider.family<List<InterviewSession>, String>((ref, uid) {
  return ref.watch(sprint5RepositoryProvider).watchInterviewSessions(uid);
});

// Study Groups Streams
final studyGroupsProvider = StreamProvider<List<StudyGroup>>((ref) {
  return ref.watch(sprint5RepositoryProvider).watchStudyGroups();
});

// Group Messages Streams
final groupMessagesProvider =
    StreamProvider.family<List<GroupMessage>, String>((ref, groupId) {
  return ref.watch(sprint5RepositoryProvider).watchGroupMessages(groupId);
});

// Community Forum Streams
final forumPostsProvider = StreamProvider<List<Post>>((ref) {
  return ref.watch(sprint5RepositoryProvider).watchPosts();
});

final forumCommentsProvider =
    StreamProvider.family<List<Comment>, String>((ref, postId) {
  return ref.watch(sprint5RepositoryProvider).watchComments(postId);
});

// Premium Subscription Streams
final subscriptionProvider = StreamProvider.family<Subscription?, String>((ref, uid) {
  return ref.watch(sprint5RepositoryProvider).watchSubscription(uid);
});

// Career Roadmap Streams
final careerRoadmapProvider =
    StreamProvider.family<CareerRoadmap?, String>((ref, uid) {
  return ref.watch(sprint5RepositoryProvider).watchCareerRoadmap(uid);
});

class Sprint5State {
  final ExamType selectedExam;
  final String interviewTopic;
  final String interviewAnswer;
  final InterviewSession? lastInterviewSession;
  final String groupName;
  final String groupDescription;
  final String groupTopic;
  final StudyGroup? selectedStudyGroup;
  final String postTitle;
  final String postContent;
  final String postCategory;
  final Post? selectedPost;
  final String forumComment;
  final String careerGoal;
  final String targetRole;
  final int targetScore;
  final String universitySearch;
  final String scholarshipSearch;
  final bool isLoading;
  final String? error;
  final CareerRoadmap? careerRoadmap;
  final Subscription? subscription;
  final String selectedPlan;

  const Sprint5State({
    this.selectedExam = ExamType.ielts,
    this.interviewTopic = 'Leadership',
    this.interviewAnswer = '',
    this.lastInterviewSession,
    this.groupName = '',
    this.groupDescription = '',
    this.groupTopic = 'Reading',
    this.selectedStudyGroup,
    this.postTitle = '',
    this.postContent = '',
    this.postCategory = 'General Advice',
    this.selectedPost,
    this.forumComment = '',
    this.careerGoal = '',
    this.targetRole = '',
    this.targetScore = 100,
    this.universitySearch = '',
    this.scholarshipSearch = '',
    this.isLoading = false,
    this.error,
    this.careerRoadmap,
    this.subscription,
    this.selectedPlan = 'Pro',
  });

  Sprint5State copyWith({
    ExamType? selectedExam,
    String? interviewTopic,
    String? interviewAnswer,
    InterviewSession? lastInterviewSession,
    String? groupName,
    String? groupDescription,
    String? groupTopic,
    StudyGroup? selectedStudyGroup,
    String? postTitle,
    String? postContent,
    String? postCategory,
    Post? selectedPost,
    String? forumComment,
    String? careerGoal,
    String? targetRole,
    int? targetScore,
    String? universitySearch,
    String? scholarshipSearch,
    bool? isLoading,
    String? error,
    CareerRoadmap? careerRoadmap,
    Subscription? subscription,
    String? selectedPlan,
  }) {
    return Sprint5State(
      selectedExam: selectedExam ?? this.selectedExam,
      interviewTopic: interviewTopic ?? this.interviewTopic,
      interviewAnswer: interviewAnswer ?? this.interviewAnswer,
      lastInterviewSession: lastInterviewSession ?? this.lastInterviewSession,
      groupName: groupName ?? this.groupName,
      groupDescription: groupDescription ?? this.groupDescription,
      groupTopic: groupTopic ?? this.groupTopic,
      selectedStudyGroup: selectedStudyGroup ?? this.selectedStudyGroup,
      postTitle: postTitle ?? this.postTitle,
      postContent: postContent ?? this.postContent,
      postCategory: postCategory ?? this.postCategory,
      selectedPost: selectedPost ?? this.selectedPost,
      forumComment: forumComment ?? this.forumComment,
      careerGoal: careerGoal ?? this.careerGoal,
      targetRole: targetRole ?? this.targetRole,
      targetScore: targetScore ?? this.targetScore,
      universitySearch: universitySearch ?? this.universitySearch,
      scholarshipSearch: scholarshipSearch ?? this.scholarshipSearch,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      careerRoadmap: careerRoadmap ?? this.careerRoadmap,
      subscription: subscription ?? this.subscription,
      selectedPlan: selectedPlan ?? this.selectedPlan,
    );
  }
}

class Sprint5Notifier extends StateNotifier<Sprint5State> {
  final Sprint5Repository _repository;

  Sprint5Notifier(this._repository) : super(const Sprint5State());

  void setExam(ExamType exam) => state = state.copyWith(selectedExam: exam);
  void setInterviewTopic(String topic) =>
      state = state.copyWith(interviewTopic: topic);
  void setInterviewAnswer(String answer) =>
      state = state.copyWith(interviewAnswer: answer);
  void setGroupName(String name) => state = state.copyWith(groupName: name);
  void setGroupDescription(String desc) =>
      state = state.copyWith(groupDescription: desc);
  void setGroupTopic(String topic) => state = state.copyWith(groupTopic: topic);
  void setPostTitle(String title) => state = state.copyWith(postTitle: title);
  void setPostContent(String content) =>
      state = state.copyWith(postContent: content);
  void setPostCategory(String category) =>
      state = state.copyWith(postCategory: category);
  void setForumComment(String comment) =>
      state = state.copyWith(forumComment: comment);
  void setCareerGoal(String goal) => state = state.copyWith(careerGoal: goal);
  void setTargetRole(String role) => state = state.copyWith(targetRole: role);
  void setTargetScore(int score) => state = state.copyWith(targetScore: score);
  void setUniversitySearch(String search) =>
      state = state.copyWith(universitySearch: search);
  void setScholarshipSearch(String search) =>
      state = state.copyWith(scholarshipSearch: search);
  void setSelectedPlan(String plan) =>
      state = state.copyWith(selectedPlan: plan);

  Future<void> conductInterview(String uid, String displayName) async {
    if (state.interviewAnswer.trim().isEmpty) {
      state = state.copyWith(error: 'Please provide an answer first.');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final session = await _repository.conductInterviewSession(
        uid: uid,
        displayName: displayName,
        topic: state.interviewTopic,
        userAnswer: state.interviewAnswer,
      );
      state = state.copyWith(
        isLoading: false,
        lastInterviewSession: session,
        interviewAnswer: '',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createStudyGroup(String uid, String displayName) async {
    if (state.groupName.isEmpty || state.groupDescription.isEmpty) {
      state = state.copyWith(error: 'Fill all group details.');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final group = await _repository.createStudyGroup(
        uid: uid,
        displayName: displayName,
        name: state.groupName,
        description: state.groupDescription,
        topic: state.groupTopic,
        examType: state.selectedExam.displayName,
      );
      state = state.copyWith(
        isLoading: false,
        selectedStudyGroup: group,
        groupName: '',
        groupDescription: '',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createPost(String uid, String displayName) async {
    if (state.postTitle.isEmpty || state.postContent.isEmpty) {
      state = state.copyWith(error: 'Fill post title and content.');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.createPost(
        uid: uid,
        displayName: displayName,
        title: state.postTitle,
        content: state.postContent,
        category: state.postCategory,
      );
      state = state.copyWith(
        isLoading: false,
        postTitle: '',
        postContent: '',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> generateCareerRoadmap(String uid) async {
    if (state.careerGoal.isEmpty || state.targetRole.isEmpty) {
      state = state.copyWith(error: 'Fill career goal and target role.');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final roadmap = await _repository.generateCareerRoadmap(
        uid: uid,
        careerGoal: state.careerGoal,
        targetRole: state.targetRole,
        examType: state.selectedExam.displayName,
        targetScore: state.targetScore,
      );
      state = state.copyWith(isLoading: false, careerRoadmap: roadmap);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> upgradeToPremium(String uid) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.upgradeToPremium(
        uid: uid,
        plan: state.selectedPlan,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
