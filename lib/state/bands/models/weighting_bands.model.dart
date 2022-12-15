import 'weighting_band.model.dart';

class WeightingBands {
  late String id;
  late String name;
  late List<WeightingBand> bands;

  WeightingBands([input, key]) {
    id = input?['id'] ?? "";
    name = input?['name'] ?? "";

    bands = input['bands'] != null
        ? input['bands'].map<WeightingBand>((d) => WeightingBand(d)).toList()
        : [];

    if (key != null) {
      id = key;
    }
  }

  WeightingBands.init({this.id = "", this.name = "", this.bands = const []});

  getJson() {
    return {
      'id': id,
      'name': name,
      'bands': bands.map((band) => band.getJson()).toList(),
    };
  }
}
