class Attribute {
  late String name;
  late String id;
  late double weight;

  Attribute([input, key]) {
    try {
      name = input?['name'] ?? "";
      id = input?['id'] ?? "";
      weight = input?['weight'] ?? 0;

      //Matching old db, attributes do not always have an ID field
      if (key != null) {
        id = key;
      }
    } catch (e) {
      print("AttID: $key");
    }
  }

  Attribute.init({required this.name, this.id = "", required this.weight});

  Attribute.empty({this.name = "", this.id = "", this.weight = 0});

  getJson() {
    return {
      "name": name,
      "id": id,
      "weight": weight,
    };
  }
}
