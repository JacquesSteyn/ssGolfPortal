import 'package:flutter/material.dart';

import '../state/shared_models/tip_group.model.dart';
import '../state/shared_models/tip_single.model.dart';
import '../widgets/custom_text_field.dart';

class TipInputs extends StatefulWidget {
  const TipInputs({Key? key, required this.tips}) : super(key: key);

  final List<TipGroup> tips;

  @override
  State<TipInputs> createState() => _TipInputsState();
}

class _TipInputsState extends State<TipInputs> {
  Widget tipInput(TipGroup tGroup) => Column(
        children: [
          Row(
            key: UniqueKey(),
            children: [
              const Text(
                "Tip",
                style: TextStyle(fontSize: 16),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    List<TipSingle> tsList = [
                      ...tGroup.tips,
                      TipSingle.empty()
                    ];
                    tGroup.tips = tsList;
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
              itemCount: tGroup.tips.length,
              shrinkWrap: true,
              controller: ScrollController(),
              itemBuilder: (_, subIndex) {
                TipSingle element = tGroup.tips[subIndex];
                return Card(
                  key: UniqueKey(),
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 200,
                          child: SwitchListTile(
                              title: const Text("Check Mark?"),
                              value: tGroup.tips[subIndex].checked,
                              onChanged: (val) {
                                setState(() {
                                  tGroup.tips[subIndex].checked = val;
                                });
                              }),
                        ),
                        Expanded(
                            key: UniqueKey(),
                            child: CustomTextField(
                                "Tip Name",
                                (val) {
                                  tGroup.tips[subIndex].text = val;
                                },
                                initialValue: element.text,
                                onChange: (val) {
                                  tGroup.tips[subIndex].text = val;
                                })),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              tGroup.tips.removeAt(subIndex);
                            });
                          },
                          tooltip: "Delete tip",
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        )
                      ],
                    ),
                  ),
                );
              })
        ],
      );

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
                  "Tip Groups",
                  style: TextStyle(fontSize: 16),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      widget.tips.add(TipGroup.empty());
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
                itemCount: widget.tips.length,
                shrinkWrap: true,
                controller: ScrollController(),
                itemBuilder: (_, index) {
                  TipGroup tGroup = widget.tips[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 30),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: CustomTextField(
                                      "Group Name",
                                      (val) {
                                        widget.tips[index].title = val;
                                      },
                                      initialValue: tGroup.title,
                                      onChange: (val) {
                                        widget.tips[index].title = val;
                                      })),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    widget.tips.removeAt(index);
                                  });
                                },
                                tooltip: "Delete tip group",
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              )
                            ],
                          ),
                          tipInput(tGroup)
                        ],
                      ),
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }
}
