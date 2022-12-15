class FieldInputSelectOption {
  String? option;
  double? score;

  FieldInputSelectOption([input]) {
    option = input?['option'];
    score = input?['score'];
  }

  FieldInputSelectOption.empty({
    this.option = "",
    this.score = 0,
  });

  getJson() {
    return {
      'option': option,
      'score': score,
    };
  }
}
