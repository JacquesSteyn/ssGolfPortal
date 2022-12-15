import 'attribute.model.dart';
import 'attribute_weighting.model.dart';

class AttributeWeightings {
  late Attribute? attribute;
  late List<AttributeWeighting> weightings;

  AttributeWeightings([input]) {
    attribute = Attribute(input?['attribute']);
    weightings = input['weightings'] != null
        ? input['weightings']
            .map<AttributeWeighting>((d) => AttributeWeighting(d))
            .toList()
        : [];
  }

  AttributeWeightings.init({required this.attribute, required this.weightings});

  AttributeWeightings.empty({this.attribute, this.weightings = const []});

  getJson() {
    return {
      'attribute': attribute?.getJson(),
      'weightings': weightings.map((e) => e.getJson()),
    };
  }
}
