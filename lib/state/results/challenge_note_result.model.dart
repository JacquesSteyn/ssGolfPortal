class ChallengeNoteResult {
  String? title, selectedOption;
  int? index;

  ChallengeNoteResult([data]) {
    if (data != null) {
      title = data['title'];
      selectedOption = data['selectedOption']; // ?? 'none';
      index = data['index'];
    }
  }

  getJson() {
    if (selectedOption == null) {
      return {
        'title': "",
        'selectedOption': "",
      };
    } else {
      return {
        'title': title,
        'selectedOption': selectedOption,
      };
    }
  }
}
