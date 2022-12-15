class WeightingBand {
  late int id;
  late int upperRange;
  late int lowerRange;
  late int percentage;
  late int numberOfPreviousResults;

  WeightingBand([input, key]) {
    id = input?['id'] ?? 0;
    upperRange = input?['upperRange'] ?? 0;
    lowerRange = input?['lowerRange'] ?? 0;
    percentage = input?['percentage'] ?? 0;
    numberOfPreviousResults = input?['numberOfPreviousResults'] ?? 0;
  }

  WeightingBand.empty(
      {this.id = 0,
      this.upperRange = 0,
      this.lowerRange = 0,
      this.percentage = 0,
      this.numberOfPreviousResults = 0});

  getJson() {
    return {
      'upperRange': upperRange,
      'lowerRange': lowerRange,
      'percentage': percentage,
      'numberOfPreviousResults': numberOfPreviousResults,
      'id': id,
    };
  }
}
