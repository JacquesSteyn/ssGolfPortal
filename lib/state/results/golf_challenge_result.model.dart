import 'challenge_input_result.model.dart';
import 'challenge_note_result.model.dart';

class GolfChallengeResult {
  String? skillIdElementId;
  String? challengeId, challengeName, difficulty, dateTimeCreated, index;
  List<ChallengeNoteResult>? notes;
  List<dynamic>? inputResults;
  double? percentage;

  GolfChallengeResult([data, key]) {
    if (data != null) {
      index = data['index'];
      challengeId = data['challengeId'];
      challengeName = data['challengeName'] ?? '';
      difficulty = data['difficulty'] ?? '0';
      percentage = data['percentage'].toDouble();
      dateTimeCreated = data['dateTimeCreated'] ?? '';
      inputResults = data['inputResults'] != null
          ? (data?['inputResults'] as Iterable).map((resultData) {
              if (resultData['type'] == 'select') {
                return ChallengeInputSelectResult(resultData);
              } else if (resultData['type'] == 'select-score') {
                return ChallengeInputSelectScoreResult(resultData);
              } else if (resultData['type'] == 'score') {
                return ChallengeInputScoreResult(resultData);
              }
            }).toList()
          : [];

      if (data['notes'] != null) {
        try {
          notes = (data?['notes'] as Iterable).map((noteData) {
            return ChallengeNoteResult(noteData);
          }).toList();
        } catch (error) {
          print(error);
        }
      } else {
        notes = [];
      }
    }
  }

  getJson() {
    Map<String, dynamic> jsonObject = {
      'index': index,
      'challengeId': challengeId ?? '',
      'challengeName': challengeName ?? '',
      'difficulty': difficulty ?? '0',
      'inputResults': inputResults!
          .map((dynamic challengeInputResult) => challengeInputResult.getJson())
          .toList(),
      'notes': notes!.map((note) => note.getJson()).toList(),
      'percentage': percentage ?? 0.0,
      'dateTimeCreated': dateTimeCreated,
    };

    return jsonObject;
  }
}
