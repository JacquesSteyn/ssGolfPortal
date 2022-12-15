import 'element_weighting.model.dart';

class SkillElementWeightings {
  late String skill;
  late String skillId;
  late String elementId;
  late List<ElementWeighting> weightings;

  SkillElementWeightings([input]) {
    skill = input?['skill'];
    skillId = input?['skillId'];
    elementId = (input?['elementId']).toString();
    weightings = input['weightings'] != null
        ? input['weightings']
            .map<ElementWeighting>((d) => ElementWeighting(d))
            .toList()
        : [];
  }

  SkillElementWeightings.empty(
      {this.skill = "",
      this.skillId = "",
      this.elementId = "",
      this.weightings = const []});

  getJson() {
    return {
      'skill': skill,
      'skillId': skillId,
      'elementId': int.parse(elementId),
      'weightings': weightings.map((e) => e.getJson()),
    };
  }
}
