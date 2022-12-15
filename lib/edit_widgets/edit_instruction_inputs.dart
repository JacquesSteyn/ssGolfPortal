import 'package:flutter/material.dart';

import '../widgets/custom_text_field.dart';

class InstructionInputs extends StatefulWidget {
  const InstructionInputs({Key? key, required this.instructions})
      : super(key: key);

  final List<String> instructions;

  @override
  State<InstructionInputs> createState() => _InstructionInputsState();
}

class _InstructionInputsState extends State<InstructionInputs> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  "Instructions",
                  style: TextStyle(fontSize: 16),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      widget.instructions.add("");
                    });
                  },
                  icon: const Icon(
                    Icons.add,
                    color: Colors.blueAccent,
                  ),
                )
              ],
            ),
            ListView.builder(
                itemCount: widget.instructions.length,
                shrinkWrap: true,
                controller: ScrollController(),
                itemBuilder: (_, index) {
                  String element = widget.instructions[index];
                  return Row(
                    children: [
                      Expanded(
                          child: CustomTextField(
                              "Instruction Name",
                              (val) {
                                widget.instructions[index] = val;
                              },
                              initialValue: element,
                              onChange: (val) {
                                widget.instructions[index] = val;
                              })),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            widget.instructions.removeAt(index);
                          });
                        },
                        tooltip: (element.isEmpty)
                            ? "Delete instruction"
                            : "Delete $element",
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      )
                    ],
                  );
                })
          ],
        ),
      ),
    );
  }
}
