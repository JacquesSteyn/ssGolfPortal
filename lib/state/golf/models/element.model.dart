class SkillElement {
  late String name;
  late int id;
  late double weight;

  SkillElement([input, key]) {
    name = input?['name'];
    id = input?['id'] as int;
    weight = input?['weight'];

    if (key != null) {
      id = key;
    }
  }

  SkillElement.init({required this.name, this.id = 0, required this.weight});

  getJson() {
    return {
      'name': name,
      'id': id,
      'weight': weight,
    };
  }
}
