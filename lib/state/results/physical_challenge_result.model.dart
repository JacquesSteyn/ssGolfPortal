import 'challenge_input_result.model.dart';
import 'challenge_note_result.model.dart';

class PhysicalChallengeResult {
  String? challengeId, challengeName, difficulty, dateTimeCreated, index;
  List<ChallengeNoteResult>? notes;
  List<dynamic>? inputResults;
  double? percentage;

  late List<AttributeContribution> attributeContributions;

  PhysicalChallengeResult([data, attributeId]) {
    if (data != null) {
      index = data['index'];
      challengeId = data['challengeId'];
      challengeName = data['challengeName'];
      difficulty = data['difficulty'];
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

      notes = data['notes'] != null
          ? (data?['notes'] as Iterable).map((noteData) {
              return ChallengeNoteResult(noteData);
            }).toList()
          : [];

      attributeContributions = [];
      if (attributeId != null) {
        attributeContributions = [
          AttributeContribution({
            'attributeId': attributeId,
            'percentage': data[attributeId]['value'],
          })
        ];
      }
    } else {
      attributeContributions = [];
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

    for (var e in attributeContributions) {
      jsonObject['${e.attributeId}'] = {
        'value': e.percentage,
        'attributeId_index': '${e.attributeId}_$index'
      };
    }

    return jsonObject;
  }
}

class AttributeContribution {
  double? percentage;
  String? attributeId;

  AttributeContribution([data]) {
    if (data != null) {
      percentage = data['percentage'].toDouble();
      attributeId = data['attributeId'] ?? '';
    }
  }

  getJson() {
    return {
      'percentage': percentage,
      'attributeId': attributeId ?? '',
    };
  }
}
