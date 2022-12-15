import '../../physical/models/attribute.model.dart';
import '../../shared_models/benchmark.model.dart';
import 'element.model.dart';

class Skill {
  late String name;
  late String iconName;
  late String id;
  late int index;
  late List<SkillElement> elements;
  late List<Attribute> attributes;
  late Benchmark benchmarks;

  Skill([input, key]) {
    name = input?['name'] ?? "";
    iconName = input?['iconName'] ?? "";
    id = input?['id'] ?? "";
    index = input?['index'] ?? 0;
    elements = (input?['elements'] != null)
        ? (input?['elements'] as Iterable)
            .map((tipData) => SkillElement(tipData))
            .toList()
        : [];

    attributes = input?['attributes'] != null
        ? (input?['attributes'] as Iterable)
            .map((tipData) => Attribute(tipData))
            .toList()
        : [];
    benchmarks = Benchmark(input?['benchmarks']);

    if (key != null) {
      id = key;
    }
  }

  Skill.init(
      {required this.name,
      required this.iconName,
      this.id = "",
      required this.index,
      required this.elements,
      required this.attributes,
      required this.benchmarks});

  getJson() {
    return {
      "name": name,
      "iconName": iconName,
      "index": index,
      "id": id,
      "elements": elements.map((element) => element.getJson()).toList(),
      "attributes": attributes.map((attribute) => attribute.getJson()).toList(),
      "benchmarks": benchmarks.getJson(),
    };
  }
}
