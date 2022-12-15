import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smartgolfportal/widgets/custom_text_field.dart';

import '../state/draws/models/voucher.model.dart';
import '../state/draws/models/voucher.state.dart';
import '../state/user/models/user.model.dart';
import '../widgets/navigation.dart';

class VoucherViewScreen extends StatelessWidget {
  VoucherViewScreen({Key? key}) : super(key: key);

  final customDate = DateFormat.yMMMEd();
  final customTime = DateFormat.Hm();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NavigationWidget(
        activePage: "Vouchers",
        titleOverride: "Voucher Info",
        showSearchBar: false,
        actions: [
          ElevatedButton.icon(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              icon: const Icon(Icons.arrow_back),
              label: const Text("Back"),
              onPressed: () => Get.back()),
        ],
        child: Consumer(builder: (context, ref, child) {
          Voucher? voucher = ref.read(voucherStateProvider).activeVoucher;
          if (voucher == null) {
            return const Center(
              child: Text("No data loaded. Please try again."),
            );
          } else {
            return SingleChildScrollView(
              controller: ScrollController(),
              child: LayoutBuilder(
                builder: (context, constraints) => Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomTextField(
                          "Vouchers Used",
                          (val) => {},
                          initialValue:
                              "${voucher.redeemedVouchers.length}/${voucher.voucherAllowedEntries}",
                          readOnly: true,
                          width: Get.width * 0.2,
                        ),
                        CustomTextField(
                          "Expiry Date",
                          (val) => {},
                          initialValue: voucher.voucherExpireDate.toString(),
                          readOnly: true,
                          width: Get.width * 0.2,
                        ),
                        CustomTextField(
                          "Voucher Value",
                          (val) => {},
                          initialValue: voucher.voucherPrice.toString(),
                          readOnly: true,
                          width: Get.width * 0.2,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: const [
                        Text(
                          "Vouchers Redeemed",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    FutureBuilder(
                      future: ref
                          .read(voucherStateProvider.notifier)
                          .fetchVoucherUsers(voucher),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData) {
                            Map<String, User> userData =
                                snapshot.data as Map<String, User>;
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                constraints: BoxConstraints(
                                    minWidth: constraints.maxWidth),
                                child: DataTable(
                                  columnSpacing: 5,
                                  headingRowColor: MaterialStateProperty.all(
                                      Get.theme.primaryColor),
                                  columns: const [
                                    DataColumn(
                                      label: Flexible(
                                        child: Text(
                                          "Name",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              decoration:
                                                  TextDecoration.underline),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Flexible(
                                        child: Text(
                                          "Email",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              decoration:
                                                  TextDecoration.underline),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Flexible(
                                        child: Text(
                                          "Date Redeemed",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              decoration:
                                                  TextDecoration.underline),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Flexible(
                                        child: Text(
                                          "Time Redeemed",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              decoration:
                                                  TextDecoration.underline),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Flexible(
                                        child: Text(
                                          "Plan",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              decoration:
                                                  TextDecoration.underline),
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows: voucher.redeemedVouchers
                                      .map((redemption) {
                                    User? user = userData[redemption.userID];

                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Text(user?.name ?? "Unknown"),
                                        ),
                                        DataCell(
                                          Text(user?.email ?? "Unknown"),
                                        ),
                                        DataCell(Text(customDate
                                            .format(redemption.redeemedDate!))),
                                        DataCell(Text(customTime
                                            .format(redemption.redeemedDate!))),
                                        DataCell(Text(user?.plan ?? "Unknown")),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return const Center(
                                child: Text(
                                    "Data could not be loaded, try again."));
                          } else {
                            return const Center(
                                child: Text("No data to show."));
                          }
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        }),
      ),
    );
  }
}
