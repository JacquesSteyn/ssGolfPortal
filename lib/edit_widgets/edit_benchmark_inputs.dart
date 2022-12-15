import 'package:flutter/material.dart';

import '../state/shared_models/benchmark.model.dart';
import '../widgets/custom_text_field.dart';

class BenchmarkInputs extends StatefulWidget {
  const BenchmarkInputs({Key? key, required this.benchmarks}) : super(key: key);

  final Benchmark benchmarks;

  @override
  State<BenchmarkInputs> createState() => _BenchmarkInputsState();
}

class _BenchmarkInputsState extends State<BenchmarkInputs> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  CustomTextField(
                    "Pro",
                    (val) => widget.benchmarks.pro = val,
                    onlyNumbers: true,
                    width: 150,
                    initialValue: widget.benchmarks.pro.toString(),
                    onChange: (val) {
                      widget.benchmarks.pro = val;
                    },
                  ),
                  CustomTextField(
                    "0-9",
                    (val) => widget.benchmarks.zero_to_nine = val,
                    onlyNumbers: true,
                    width: 150,
                    initialValue: widget.benchmarks.zero_to_nine.toString(),
                    onChange: (val) => widget.benchmarks.zero_to_nine = val,
                  ),
                  CustomTextField(
                    "10-19",
                    (val) => widget.benchmarks.ten_to_nineteen = val,
                    onlyNumbers: true,
                    width: 150,
                    initialValue: widget.benchmarks.ten_to_nineteen.toString(),
                    onChange: (val) => widget.benchmarks.ten_to_nineteen = val,
                  ),
                  CustomTextField(
                    "20-29",
                    (val) => widget.benchmarks.twenty_to_twenty_nine = val,
                    onlyNumbers: true,
                    width: 150,
                    initialValue:
                        widget.benchmarks.twenty_to_twenty_nine.toString(),
                    onChange: (val) =>
                        widget.benchmarks.twenty_to_twenty_nine = val,
                  ),
                  CustomTextField(
                    "30+",
                    (val) => widget.benchmarks.thirty_plus = val,
                    onlyNumbers: true,
                    width: 150,
                    initialValue: widget.benchmarks.thirty_plus.toString(),
                    onChange: (val) => widget.benchmarks.thirty_plus = val,
                  ),
                ],
              ),
              CustomTextField(
                "Threshold",
                () => {},
                onlyNumbers: true,
                width: 150,
                initialValue: widget.benchmarks.threshold.toString(),
                onChange: (val) => widget.benchmarks.threshold = val,
              ),
            ]),
      ],
    );
  }
}
