import 'field_input_selection_option.model.dart';

class FieldInput {
  late String type;
  late String name;
  late List<FieldInputSelectOption> selectOptions; // select type
  late int maxScore; // score type

  FieldInput([input]) {
    type = input?['type'];
    name = input?['name'];
    if (input?['type'] != "score" && input?['type'] != "inverted-score") {
      selectOptions =
          input?['selectOptions'].map<FieldInputSelectOption>((optionData) {
        return FieldInputSelectOption(optionData);
      }).toList();
    } else {
      selectOptions = [];
    }

    maxScore = input?['maxScore'] ?? 0;
  }

  FieldInput.empty(
      {this.type = "",
      this.name = "",
      this.selectOptions = const [],
      this.maxScore = 0});

  getJson() {
    if (type == "score" || type == "inverted-score") {
      return {
        'name': name,
        'type': type,
        'maxScore': maxScore,
      };
    } else {
      return {
        'name': name,
        'type': type,
        'selectOptions': selectOptions.map((option) => option.getJson()),
        'maxScore': maxScore,
      };
    }
  }
}
