import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InputPopup extends StatelessWidget {
  const InputPopup(
      {Key? key,
      required this.title,
      required this.action,
      this.actionTitle = "Save",
      required this.inputFields,
      this.widthScale = 0.4})
      : super(key: key);

  final String title;
  final List<Widget> inputFields;
  final VoidCallback action;
  final String actionTitle;
  final double widthScale;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SingleChildScrollView(
          controller: ScrollController(),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Title(
                        color: Colors.black,
                        child: Text(
                          title,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )),
                    SizedBox(
                      width: Get.width * widthScale,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(color: Colors.grey.shade300, height: 5),
                          ...inputFields.map((input) => input).toList(),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: ElevatedButton(
                                  onPressed: action, child: Text(actionTitle)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ],
    );
  }
}
