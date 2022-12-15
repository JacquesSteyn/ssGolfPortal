import 'tip_single.model.dart';

class TipGroup {
  late String title;
  late List<TipSingle> tips;

  TipGroup([input]) {
    title = input?['title'];
    tips = (input?['tips'] as Iterable)
        .map((tipData) => TipSingle(tipData))
        .toList();
  }

  TipGroup.empty({this.title = "", this.tips = const []});

  getJson() {
    return {
      'title': title,
      'tips': tips.map((tip) => tip.getJson()),
    };
  }
}
