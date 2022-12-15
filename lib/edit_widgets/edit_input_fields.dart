import 'package:flutter/material.dart';
import 'package:smartgolfportal/state/shared_models/field_input.model.dart';

import '../constants/data.dart';
import '../state/shared_models/field_input_selection_option.model.dart';
import '../widgets/custom_text_field.dart';

class InputField extends StatefulWidget {
  const InputField({Key? key, required this.fieldInputs}) : super(key: key);

  final List<FieldInput> fieldInputs;

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                "Inputs",
                style: TextStyle(fontSize: 16),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    widget.fieldInputs.add(FieldInput.empty());
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
              itemCount: widget.fieldInputs.length,
              shrinkWrap: true,
              controller: ScrollController(),
              itemBuilder: (_, index) {
                FieldInput element = widget.fieldInputs[index];

                return Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: CustomTextField(
                                  "Name*",
                                  (val) {
                                    widget.fieldInputs[index].name = val;
                                  },
                                  initialValue: element.name,
                                  onChange: (val) {
                                    widget.fieldInputs[index].name = val;
                                  }),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Score Type*",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                Container(
                                  key: UniqueKey(),
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(8)),
                                  margin:
                                      const EdgeInsets.only(top: 5, bottom: 20),
                                  child: DropdownButton(
                                    value: widget.fieldInputs[index].type,
                                    alignment: Alignment.center,
                                    items: inputTypes
                                        .map((e) => DropdownMenuItem(
                                              child: Text(
                                                e['label'] ?? "",
                                                textAlign: TextAlign.center,
                                              ),
                                              value: e['value'],
                                            ))
                                        .toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        widget.fieldInputs[index].type =
                                            val.toString();
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            if (widget.fieldInputs[index].type != "select")
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: SizedBox(
                                    width: 200,
                                    child: CustomTextField(
                                        "Max Score",
                                        (val) {
                                          widget.fieldInputs[index].maxScore =
                                              int.parse(val);
                                        },
                                        initialValue:
                                            element.maxScore.toString(),
                                        onlyNumbers: true,
                                        onChange: (val) {
                                          widget.fieldInputs[index].maxScore =
                                              int.parse(val);
                                        })),
                              ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  widget.fieldInputs.removeAt(index);
                                });
                              },
                              tooltip: "Delete input",
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            )
                          ],
                        ),
                        if (widget.fieldInputs[index].type == "select" ||
                            widget.fieldInputs[index].type == "select-score")
                          Card(
                            elevation: 10,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        "Options",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          List<FieldInputSelectOption> temp = [
                                            ...element.selectOptions
                                          ];

                                          temp.add(
                                              FieldInputSelectOption.empty());

                                          setState(() {
                                            element.selectOptions = temp;
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
                                      itemCount: element.selectOptions.length,
                                      shrinkWrap: true,
                                      controller: ScrollController(),
                                      itemBuilder: (_, subIndex) {
                                        FieldInputSelectOption option = widget
                                            .fieldInputs[index]
                                            .selectOptions[subIndex];

                                        return Row(
                                          children: [
                                            Expanded(
                                                child: CustomTextField(
                                                    "Option Name",
                                                    (val) {
                                                      element
                                                          .selectOptions[
                                                              subIndex]
                                                          .option = val;
                                                    },
                                                    initialValue: option.option,
                                                    onChange: (val) {
                                                      element
                                                          .selectOptions[
                                                              subIndex]
                                                          .option = val;
                                                    })),
                                            if (widget
                                                    .fieldInputs[index].type ==
                                                "select-score")
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    left: 10),
                                                child: CustomTextField(
                                                    "Option Score",
                                                    (val) {
                                                      element
                                                              .selectOptions[
                                                                  subIndex]
                                                              .score =
                                                          double.parse(val);
                                                    },
                                                    initialValue:
                                                        option.score.toString(),
                                                    onlyNumbers: true,
                                                    width: 100,
                                                    onChange: (val) {
                                                      element
                                                              .selectOptions[
                                                                  subIndex]
                                                              .score =
                                                          double.parse(val);
                                                    }),
                                              ),
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  element.selectOptions
                                                      .removeAt(subIndex);
                                                });
                                              },
                                              tooltip: "Delete option",
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
                          )
                      ],
                    ),
                  ),
                );
              })
        ],
      ),
    );
  }
}
