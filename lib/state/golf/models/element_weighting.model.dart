import 'element.model.dart';

class ElementWeighting {
  late SkillElement element;
  late int weight;

  ElementWeighting([input]) {
    element = SkillElement(input?['element']);
    weight = input?['weight'] ?? 0;
  }

  ElementWeighting.init({required this.element, required this.weight});

  getJson() {
    return {
      'element': element.getJson(),
      'weight': weight,
    };
  }
}
