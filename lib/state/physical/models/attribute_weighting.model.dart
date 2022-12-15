import 'attribute.model.dart';

class AttributeWeighting {
  late Attribute attribute;
  late int weight;
  late int id; // only used for mapping, not from DB

  AttributeWeighting([input]) {
    attribute = Attribute(input?['attribute']);
    weight = input?['weight'] ?? 0;
  }

  AttributeWeighting.init(
      {required this.attribute, required this.weight, required this.id});

  getJson() {
    return {
      'attribute': attribute.getJson(),
      'weight': weight,
    };
  }
}
