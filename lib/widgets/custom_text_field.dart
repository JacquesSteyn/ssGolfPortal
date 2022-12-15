import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  CustomTextField(this.title, this.onSave,
      {this.initialValue,
      this.onChange,
      this.onlyNumbers = false,
      this.allowDecimal = false,
      this.readOnly = false,
      this.maxLength,
      this.notRequired = false,
      Key? key,
      this.width})
      : super(key: key);

  String title;
  Function onSave;
  String? initialValue;
  Function? onChange;
  bool onlyNumbers;
  bool allowDecimal;
  double? width;
  bool readOnly;
  int? maxLength;
  bool notRequired;

  String formatVal(String val) {
    if (val.isEmpty && onlyNumbers) {
      return "0";
    } else if (onlyNumbers) {
      bool zeroCheck = val.substring(0, 1) == "0";
      if (zeroCheck) {
        return val.replaceRange(0, 1, "");
      } else {
        return val;
      }
    } else {
      return val;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: UniqueKey(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Title(
              color: Colors.black,
              child: Text(
                title,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              )),
          const SizedBox(
            height: 5,
          ),
          Container(
            width: width,
            key: UniqueKey(),
            decoration: BoxDecoration(
                color: readOnly ? Colors.grey.shade100 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            margin: const EdgeInsets.only(bottom: 20),
            child: TextFormField(
              style: TextStyle(
                  color: readOnly ? Colors.grey.shade400 : Colors.black),
              key: UniqueKey(),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              inputFormatters: onlyNumbers
                  ? <TextInputFormatter>[
                      if (allowDecimal)
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^(\d+)?\.?\d{0,2}'))
                      else
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^(\d+)?\d{0,2}')),
                    ]
                  : null,
              initialValue:
                  onlyNumbers ? (initialValue ?? "0") : (initialValue ?? ""),
              decoration: const InputDecoration(border: InputBorder.none),
              validator: (val) {
                if (notRequired) {
                  return null;
                }

                if (val == null || val.isEmpty) {
                  return '$title is required.';
                } else {
                  return null;
                }
              },
              readOnly: readOnly,
              maxLength: maxLength,
              onSaved: (val) => onSave(val),
              onChanged: (val) =>
                  onChange != null ? onChange!(formatVal(val)) : {},
            ),
          ),
        ],
      ),
    );
  }
}
