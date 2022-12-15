import 'package:flutter/material.dart';

import '../widgets/custom_text_field.dart';

class DrawRuleInputs extends StatefulWidget {
  const DrawRuleInputs({Key? key, required this.rule}) : super(key: key);

  final List<String> rule;

  @override
  State<DrawRuleInputs> createState() => _DrawRuleInputsState();
}

class _DrawRuleInputsState extends State<DrawRuleInputs> {
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
                  "Rule",
                  style: TextStyle(fontSize: 16),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      widget.rule.add("");
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
                itemCount: widget.rule.length,
                shrinkWrap: true,
                controller: ScrollController(),
                itemBuilder: (_, index) {
                  String element = widget.rule[index];

                  return Row(
                    children: [
                      Expanded(
                          child: CustomTextField(
                              "Rule Name",
                              (val) {
                                widget.rule[index] = val;
                              },
                              initialValue: element,
                              onChange: (val) {
                                widget.rule[index] = val;
                              })),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            widget.rule.removeAt(index);
                          });
                        },
                        tooltip: (element.isEmpty)
                            ? "Delete rule"
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
