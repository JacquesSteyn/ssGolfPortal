class TipSingle {
  late bool checked;
  late String text;

  TipSingle([input]) {
    checked = input?['checked'] ?? true;
    text = input?['text'];
  }

  TipSingle.empty({this.text = "", this.checked = true});

  getJson() {
    return {
      'checked': checked,
      'text': text,
    };
  }
}
