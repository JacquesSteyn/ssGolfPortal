class Note {
  late String id;
  late String title;
  late String type;
  late List<String> options;

  Note([input, key]) {
    id = input?['id'] ?? "";
    title = input?['title'] ?? "";
    type = input?['type'] ?? "";
    options = input['options'] != null
        ? input['options'].map<String>((text) => text.toString()).toList()
        : [];

    if (key != null) {
      id = key;
    }
  }

  Note.init(
      {required this.title,
      this.id = "",
      this.type = "",
      this.options = const []});

  getJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'options': options,
    };
  }
}
