import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smartgolfportal/state/draws/models/voucher.model.dart';
import 'package:smartgolfportal/state/draws/models/voucher.state.dart';

import '../router.dart';
import '../widgets/data_table.dart';
import '../widgets/navigation.dart';

class VoucherScreen extends ConsumerStatefulWidget {
  const VoucherScreen({Key? key}) : super(key: key);

  @override
  _VoucherScreenState createState() => _VoucherScreenState();
}

class _VoucherScreenState extends ConsumerState<VoucherScreen> {
  int _pageIndex = 0;
  List<Voucher> _voucherList = [];
  String _searchTerm = "";
  String _filterTerm = "all";

  final format = DateFormat('yyyy-MM-dd hh:mm');

  void setPrevious(String firstVal) {
    setState(() {
      if (_pageIndex > 0) {
        _pageIndex--;
      }
      _voucherList = ref
          .read(voucherStateProvider)
          .fetchPaginatedVoucherList(action: "minus");
    });
  }

  void setNext(String lastVal) {
    setState(() {
      _pageIndex++;
      _voucherList = ref
          .read(voucherStateProvider)
          .fetchPaginatedVoucherList(action: "plus");
    });
  }

  Widget editButton(Voucher voucher) {
    return Container(
      margin: const EdgeInsets.only(left: 2, right: 2),
      child: ElevatedButton(
        child: const Icon(
          Icons.edit,
          color: Colors.white,
        ),
        onPressed: () {
          ref
              .read(voucherStateProvider.notifier)
              .setActiveVoucher(voucher)
              .then((value) => Get.toNamed(AppRoutes.voucherEditScreen));
        },
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.blue)),
      ),
    );
  }

  Widget viewButton(Voucher voucher) {
    return Container(
      margin: const EdgeInsets.only(left: 2, right: 2),
      child: ElevatedButton(
        child: const Icon(
          Icons.remove_red_eye_outlined,
          color: Colors.black,
        ),
        onPressed: () {
          ref
              .read(voucherStateProvider.notifier)
              .setActiveVoucher(voucher)
              .then((value) => Get.toNamed(AppRoutes.voucherViewScreen));
        },
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.white)),
      ),
    );
  }

  Widget deleteButton(Voucher voucher) {
    return Container(
      margin: const EdgeInsets.only(left: 2, right: 2),
      child: ElevatedButton(
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
        onPressed: () {
          ref.read(voucherStateProvider.notifier).deleteVoucher(voucher);
        },
        style:
            ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
      ),
    );
  }

  Widget filterMenu() {
    return Row(
      children: [
        const Text("Filter by status: "),
        FutureBuilder(builder: ((context, snapshot) {
          return DropdownButton(
              value: _filterTerm,
              alignment: Alignment.center,
              items: const [
                DropdownMenuItem(
                  child: Text(
                    "All",
                    textAlign: TextAlign.center,
                  ),
                  value: "all",
                ),
                DropdownMenuItem(
                  child: Text(
                    "Active",
                    textAlign: TextAlign.center,
                  ),
                  value: "Active",
                ),
                DropdownMenuItem(
                  child: Text(
                    "Complete",
                    textAlign: TextAlign.center,
                  ),
                  value: "Complete",
                ),
                DropdownMenuItem(
                  child: Text(
                    "Expired",
                    textAlign: TextAlign.center,
                  ),
                  value: "Expired",
                ),
                DropdownMenuItem(
                  child: Text(
                    "Canceled",
                    textAlign: TextAlign.center,
                  ),
                  value: "Canceled",
                ),
              ],
              onChanged: (val) => {
                    setState(() {
                      _filterTerm = val.toString();
                      _pageIndex = 0;
                    })
                  });
        })),
      ],
    );
  }

  void setSearchTerm(String? term) {
    setState(() {
      _searchTerm = term ?? "";
      _pageIndex = 0;
    });
  }

  @override
  void initState() {
    super.initState();
    var voucherProvider = ref.read(voucherStateProvider.notifier);
    voucherProvider.initVoucherList();
  }

  @override
  Widget build(BuildContext context) {
    const double _responsiveWidth = 1500;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: NavigationWidget(
          activePage: "Vouchers",
          actions: [
            filterMenu(),
            const SizedBox(
              width: 30,
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Create New Voucher"),
              onPressed: () {
                ref.read(voucherStateProvider.notifier).setActiveVoucher(null);
                Get.toNamed(AppRoutes.voucherEditScreen);
              },
            )
          ],
          searchFunction: setSearchTerm,
          child: SingleChildScrollView(
              controller: ScrollController(),
              child: CustomDataTable(
                pageIndex: _pageIndex,
                onPrevious: (firstVal) => setPrevious(firstVal),
                onNext: (lastVal) => setNext(lastVal),
                dataReady: !ref.watch(voucherStateProvider).isLoading,
                dataColumns: const [
                  'Voucher Name',
                  'Status',
                  'Voucher No',
                  'Used',
                  'Exp. Date',
                  "Action"
                ],
                lastVal: ref.watch(voucherStateProvider).dataRange.toString(),
                dataRows: ref
                    .watch(voucherStateProvider)
                    .fetchPaginatedVoucherList(
                        searchTerm: _searchTerm, filter: _filterTerm)
                    .map((voucher) {
                  return DataRow(cells: [
                    DataCell(Text(voucher.voucherName)),
                    DataCell(Text(voucher.voucherStatus)),
                    DataCell(Text(voucher.voucherNumber)),
                    DataCell(Text(voucher.redeemedVouchers.length.toString() +
                        " / " +
                        voucher.voucherAllowedEntries.toString())),
                    DataCell(Text(voucher.voucherExpireDate != null
                        ? format.format(voucher.voucherExpireDate!)
                        : "Unknown")),
                    DataCell(Row(
                      children: [
                        editButton(voucher),
                        viewButton(voucher),
                        deleteButton(voucher)
                      ],
                    ))
                  ]);
                }).toList(),
              ))),
    );
  }
}
