class Benchmark {
  late String pro;
  late String zero_to_nine;
  late String ten_to_nineteen;
  late String twenty_to_twenty_nine;
  late String thirty_plus;
  late String threshold;

  Benchmark([input]) {
    pro = input?['pro'].toString() ?? "0";
    zero_to_nine = input?['zero_to_nine'].toString() ?? "0";
    ten_to_nineteen = input?['ten_to_nineteen'].toString() ?? "0";
    twenty_to_twenty_nine = input?['twenty_to_twenty_nine'].toString() ?? "0";
    thirty_plus = input?['thirty_plus'].toString() ?? "0";
    threshold = input?['threshold'].toString() ?? "0";
  }

  Benchmark.init(
      {required this.pro,
      required this.zero_to_nine,
      required this.ten_to_nineteen,
      required this.twenty_to_twenty_nine,
      required this.thirty_plus,
      this.threshold = "0"});

  Benchmark.empty(
      {this.pro = "0",
      this.zero_to_nine = "0",
      this.ten_to_nineteen = "0",
      this.twenty_to_twenty_nine = "0",
      this.thirty_plus = "0",
      this.threshold = "0"});

  getJson() {
    return {
      "pro": pro,
      "zero_to_nine": zero_to_nine,
      "ten_to_nineteen": ten_to_nineteen,
      "twenty_to_twenty_nine": twenty_to_twenty_nine,
      "thirty_plus": thirty_plus,
      "threshold": threshold,
    };
  }
}
