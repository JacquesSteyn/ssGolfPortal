import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import 'package:smartgolfportal/widgets/custom_text_field.dart';

import '../state/draws/models/voucher.model.dart';
import '../state/draws/models/voucher.state.dart';
import '../widgets/navigation.dart';

class VoucherEditScreen extends ConsumerStatefulWidget {
  const VoucherEditScreen({Key? key}) : super(key: key);

  @override
  _VoucherEditScreenState createState() => _VoucherEditScreenState();
}

class _VoucherEditScreenState extends ConsumerState<VoucherEditScreen> {
  bool isLoading = true;
  String errorMessage = "";
  bool newVoucher = true;
  Voucher? oldVoucher;
  bool didCopy = false;

  DateFormat customDateFormat = DateFormat("d/M/y");

  final GlobalKey<FormState> _VoucherFormKey = GlobalKey<FormState>();
  final TextEditingController textController = TextEditingController();

  //inputs
  late String id = "";
  late String voucherName = "";
  late String voucherStatus = ""; // Active, Complete, Expired, Canceled
  late String voucherNumber = "";
  late double voucherPrice = 0;
  late int voucherAllowedEntries = 1;
  late DateTime? voucherExpireDate = DateTime.now();
  late List<RedeemedVoucher> redeemedVouchers = [];

  ///

  saveVoucher() {
    if (_VoucherFormKey.currentState!.validate()) {
      voucherNumber = textController.text;

      Voucher voucher = Voucher.init(
        id: id,
        voucherName: voucherName,
        voucherStatus: voucherStatus,
        voucherNumber: voucherNumber,
        voucherPrice: voucherPrice,
        voucherAllowedEntries: voucherAllowedEntries,
        voucherExpireDate: voucherExpireDate,
        redeemedVouchers: redeemedVouchers,
      );

      if (newVoucher) {
        voucherStatus = "Active";
        ref
            .read(voucherStateProvider.notifier)
            .createNewVoucher(voucher)
            .then((value) {
          if (value != null) {
            Get.back();
          }
        });
      } else {
        ref
            .read(voucherStateProvider.notifier)
            .updateVoucher(oldVoucher, voucher)
            .then((value) {
          Get.back();
        });
      }
    } else {
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                title: Text("Not all fields are valid"),
              ));
    }
  }

  String calculatedAge(String? dob) {
    if (dob != null && dob.length == 10) {
      int year = DateTime.now().year - int.parse(dob.substring(0, 4));
      return year.toString();
    } else {
      return "Unknown";
    }
  }

  @override
  void initState() {
    super.initState();
    Voucher? voucher = ref.read(voucherStateProvider).activeVoucher;

    if (voucher != null) {
      setState(() {
        id = voucher.id;
        voucherName = voucher.voucherName;
        voucherStatus = voucher.voucherStatus;
        voucherNumber = voucher.voucherNumber;
        voucherPrice = voucher.voucherPrice;
        voucherAllowedEntries = voucher.voucherAllowedEntries;
        voucherExpireDate = voucher.voucherExpireDate;
        redeemedVouchers = voucher.redeemedVouchers;

        textController.text = voucherNumber;

        newVoucher = false;
        oldVoucher = voucher;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    var datePicker = Row(
      children: [
        CustomTextField(
          "Expiry Date",
          (val) => {voucherExpireDate = val},
          initialValue: voucherExpireDate != null
              ? customDateFormat.format(voucherExpireDate!)
              : null,
          readOnly: true,
          width: Get.width * 0.2,
        ),
        TextButton(
          onPressed: () {
            showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(DateTime.now().year + 2, DateTime.now().month,
                  DateTime.now().day),
            ).then((date) {
              if (date != null) {
                setState(() {
                  voucherExpireDate = DateTime(date.year, date.month, date.day);
                });
              }
            });
          },
          child: const Text("Change"),
        )
      ],
    );
    return Scaffold(
      body: NavigationWidget(
        activePage: "Vouchers",
        titleOverride: newVoucher ? "New Voucher" : "Edit Voucher",
        showSearchBar: false,
        actions: [
          ElevatedButton.icon(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              icon: const Icon(Icons.arrow_back),
              label: const Text("Back"),
              onPressed: () => Get.back()),
          const SizedBox(
            width: 20,
          ),
          if (!newVoucher)
            Container(
              margin: const EdgeInsets.only(right: 20),
              child: ElevatedButton.icon(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red)),
                  icon: const Icon(
                    Icons.block,
                  ),
                  label: const Text("Cancel Voucher"),
                  onPressed: () {
                    voucherStatus = 'Canceled';
                    saveVoucher();
                  }),
            ),
          ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: Text(newVoucher ? "Create" : "Save"),
              onPressed: () => saveVoucher())
        ],
        child: Stack(children: [
          Form(
            key: _VoucherFormKey,
            child: Column(
              children: [
                Card(
                  elevation: 8,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          "Voucher Name",
                          (val) => {voucherName = val},
                          initialValue: voucherName,
                          onChange: (val) => voucherName = val,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomTextField(
                              "Voucher Value",
                              (val) => {voucherPrice = val},
                              initialValue: voucherPrice.toString(),
                              onlyNumbers: true,
                              allowDecimal: true,
                              width: Get.width * 0.2,
                              onChange: (val) =>
                                  voucherPrice = double.parse(val),
                            ),
                            CustomTextField(
                              "Max Entries Allowed",
                              (val) => {voucherAllowedEntries = val},
                              initialValue: voucherAllowedEntries.toString(),
                              onlyNumbers: true,
                              width: Get.width * 0.2,
                              onChange: (val) =>
                                  voucherAllowedEntries = int.parse(val),
                            ),
                            datePicker,
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        if (voucherStatus != "Active")
                          Center(
                            child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.green)),
                                onPressed: () {
                                  voucherStatus = 'Active';
                                  saveVoucher();
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Activate Voucher',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                )),
                          ),
                        const SizedBox(
                          height: 10,
                        ),
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                width: Get.width * 0.3,
                                child: TextFormField(
                                  controller: textController,
                                  textAlign: TextAlign.center,
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Voucher Number is required.';
                                    } else if (val.length < 19) {
                                      return 'Voucher Number is invalid. ${val.length}';
                                    } else {
                                      return null;
                                    }
                                  },
                                  autocorrect: false,
                                  inputFormatters: [
                                    const UpperCaseTextFormatter(),
                                    MaskTextInputFormatter(
                                      mask: '####-####-####-####',
                                      filter: {
                                        "#": RegExp('[A-Z0-9]'),
                                      },
                                    )
                                  ],
                                  cursorColor: Colors.grey,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                  decoration: const InputDecoration(
                                      hintText: "XXXX-XXXX-XXXX-XXXX",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      fillColor: Color.fromARGB(84, 92, 92, 92),
                                      filled: true,
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.transparent),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.transparent),
                                      ),
                                      errorBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                      ),
                                      errorMaxLines: 1),
                                ),
                              ),
                              Positioned(
                                  left: Get.width * 0.26,
                                  child: !didCopy
                                      ? IconButton(
                                          icon: const Icon(Icons.copy_outlined),
                                          onPressed: () async {
                                            if (textController.text.length ==
                                                19) {
                                              await Clipboard.setData(
                                                  ClipboardData(
                                                      text:
                                                          textController.text));
                                              setState(() {
                                                didCopy = true;
                                              });
                                              Future.delayed(const Duration(
                                                      seconds: 1))
                                                  .then((value) => {
                                                        setState(() {
                                                          didCopy = false;
                                                        })
                                                      });
                                            }
                                          },
                                        )
                                      : const Text("Copied"))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (ref.read(voucherStateProvider).isLoading)
                  LayoutBuilder(builder: (context, constraints) {
                    return Container(
                      width: constraints.maxWidth,
                      height: screenSize.height * 0.8,
                      color: Colors.black.withOpacity(0.4),
                      child: const Center(
                        child: SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator()),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class UpperCaseTextFormatter implements TextInputFormatter {
  const UpperCaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
        text: newValue.text.toUpperCase(), selection: newValue.selection);
  }
}
