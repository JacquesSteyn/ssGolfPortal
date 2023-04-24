abstract class ChallengeInput {
  String? type, name;
  int? index, maxScore;

  ChallengeInput({
    this.type,
    this.name,
    this.index,
  });
}

class ChallengeInputSelect extends ChallengeInput {
  List<SelectOptionScore>? selectionOptions;

  ChallengeInputSelect(data, index) {
    type = data['type'];
    name = data['name'];
    this.index = index;
    // this.selectionOptions = List<String>.from(data['selectOptions'] ?? []);
    selectionOptions = List<SelectOptionScore>.from(data['selectOptions']
            .map<SelectOptionScore>(
                (selectOption) => SelectOptionScore(selectOption)) ??
        []);
  }
}

class SelectOptionScore {
  String? option;
  double? score;

  SelectOptionScore(data) {
    option = data['option'];
    score = (data['score'] ?? 0).toDouble();
  }

  getJson() {
    return {
      'option': option,
      'score': score,
    };
  }
}

class ChallengeInputSelectScore extends ChallengeInput {
  List<SelectOptionScore>? selectionOptions;

  ChallengeInputSelectScore(data, index) {
    type = data['type'];
    name = data['name'];
    maxScore = data['maxScore'];
    this.index = index;

    selectionOptions = List<SelectOptionScore>.from(data['selectOptions']
            .map<SelectOptionScore>(
                (selectOption) => SelectOptionScore(selectOption)) ??
        []);
  }
}

class ChallengeInputScore extends ChallengeInput {
  @override
  int? maxScore;

  ChallengeInputScore(data, index) {
    type = data['type'];
    name = data['name'];
    this.index = index;
    maxScore = data['maxScore'];
  }
}
