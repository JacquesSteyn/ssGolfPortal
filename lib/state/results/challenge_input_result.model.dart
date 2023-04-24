import 'challenge_input.model.dart';

abstract class ChallengeInputResult {
  String? name, type;
  int? index;
  ChallengeInputResult({this.name, this.type, this.index});
}

class ChallengeInputSelectResult implements ChallengeInputResult {
  @override
  @override
  String? selectedOption, name, type;
  @override
  int? index;

  ChallengeInputSelectResult(data) {
    name = data['name'];
    type = data['type'];
    selectedOption = data['selectedOption'];
    index = data['index'];
  }

  getJson() {
    return {
      'name': name,
      'type': type,
      'selectedOption': selectedOption,
    };
  }
}

class ChallengeInputSelectScoreResult extends ChallengeInputResult {
  SelectOptionScore? selectedOption;

  ChallengeInputSelectScoreResult(data) {
    name = data['name'];
    type = data['type'];
    selectedOption = data['selectedOption'] != null
        ? SelectOptionScore(data['selectedOption'])
        : null;
    index = data['index'];
  }

  getJson() {
    return {
      'name': name,
      'type': type,
      'selectedOption': selectedOption!.getJson(),
    };
  }
}

class ChallengeInputScoreResult implements ChallengeInputResult {
  @override
  int? selectedScore, index;
  @override
  @override
  String? name, type;

  ChallengeInputScoreResult(data) {
    name = data['name'];
    type = data['type'];
    selectedScore = data['selectedScore'] ?? -1;
    index = data['index'];
  }

  getJson() {
    return {
      'name': name,
      'type': type,
      'selectedScore': selectedScore,
    };
  }
}
