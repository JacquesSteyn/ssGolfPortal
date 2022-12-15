import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInput extends StatelessWidget {
  const CustomInput(
      {Key? key,
      required this.title,
      required this.controller,
      this.width = 200,
      this.expanded = false,
      this.isRequired = true,
      this.onlyNumbers = false,
      this.onChange})
      : super(key: key);

  final TextEditingController controller;
  final String title;
  final double width;
  final bool expanded;
  final bool isRequired;
  final bool onlyNumbers;
  final Function? onChange;

  @override
  Widget build(BuildContext context) {
    return expanded
        ? Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextFormField(
                      controller: controller,
                      inputFormatters: onlyNumbers
                          ? <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^(\d+)?\.?\d{0,2}'))
                            ]
                          : null,
                      onChanged: (val) =>
                          onChange != null ? onChange!(val) : (val) => {},
                      validator: isRequired
                          ? (val) {
                              if (val == null || val.isEmpty) {
                                return "This is required";
                              }
                              return null;
                            }
                          : null,
                      decoration:
                          const InputDecoration(border: InputBorder.none),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14),
                ),
                Container(
                  width: width,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextFormField(
                    controller: controller,
                    decoration: const InputDecoration(border: InputBorder.none),
                    onChanged: (val) =>
                        onChange != null ? onChange!(val) : (val) => {},
                    inputFormatters: onlyNumbers
                        ? <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^(\d+)?\.?\d{0,2}'))
                          ]
                        : null,
                    validator: isRequired
                        ? (val) {
                            if (val == null || val.isEmpty) {
                              return "This is required";
                            }
                            return null;
                          }
                        : null,
                  ),
                ),
              ],
            ),
          );
  }
}
