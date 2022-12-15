import 'package:flutter/material.dart';

import '../widgets/custom_text_field.dart';

class EquipmentInputs extends StatefulWidget {
  const EquipmentInputs({Key? key, required this.equipment}) : super(key: key);

  final List<String> equipment;

  @override
  State<EquipmentInputs> createState() => _EquipmentInputsState();
}

class _EquipmentInputsState extends State<EquipmentInputs> {
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
                  "Equipment",
                  style: TextStyle(fontSize: 16),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      widget.equipment.add("");
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
                itemCount: widget.equipment.length,
                shrinkWrap: true,
                controller: ScrollController(),
                itemBuilder: (_, index) {
                  String element = widget.equipment[index];

                  return Row(
                    children: [
                      Expanded(
                          child: CustomTextField(
                              "Equipment Name",
                              (val) {
                                widget.equipment[index] = val;
                              },
                              initialValue: element,
                              onChange: (val) {
                                widget.equipment[index] = val;
                              })),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            widget.equipment.removeAt(index);
                          });
                        },
                        tooltip: (element.isEmpty)
                            ? "Delete equipment"
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
