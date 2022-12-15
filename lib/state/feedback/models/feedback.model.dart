class AppFeedback {
  late String ratingNotes;
  late int rating;
  late String challengeId;
  late String userId;
  late String id;

  AppFeedback([input, key]) {
    rating = input?['rating'] ?? 0;
    ratingNotes = input?['ratingNotes'] ?? "";
    userId = input?['userId'];
    challengeId = input?['challengeId'] ?? "";
    id = input?['id'] ?? "";

    if (key != null) {
      id = key;
    }
  }
}
