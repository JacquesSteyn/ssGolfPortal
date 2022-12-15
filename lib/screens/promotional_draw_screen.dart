import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../router.dart';
import '../state/draws/draw.state.dart';
import '../state/draws/models/draw.model.dart';
import '../widgets/data_table.dart';
import '../widgets/navigation.dart';

class PromotionalDrawScreen extends ConsumerStatefulWidget {
  const PromotionalDrawScreen({Key? key}) : super(key: key);

  @override
  _PromotionalDrawScreenState createState() => _PromotionalDrawScreenState();
}

class _PromotionalDrawScreenState extends ConsumerState<PromotionalDrawScreen> {
  int _pageIndex = 0;
  List<PromotionalDraw> _promoDraws = [];
  String _searchTerm = "";
  String _filterTerm = "all";
  bool _filterClosed = false;

  final format = DateFormat('yyyy-MM-dd hh:mm');

  void setPrevious(String firstVal) {
    setState(() {
      if (_pageIndex > 0) {
        _pageIndex--;
      }
      _promoDraws =
          ref.read(drawStateProvider).fetchPaginatedDrawList(action: "minus");
    });
  }

  void setNext(String lastVal) {
    setState(() {
      _pageIndex++;
      _promoDraws =
          ref.read(drawStateProvider).fetchPaginatedDrawList(action: "plus");
    });
  }

  Widget editButton(PromotionalDraw draw) {
    return Container(
      margin: const EdgeInsets.only(left: 2, right: 2),
      child: ElevatedButton(
        child: const Icon(
          Icons.edit,
          color: Colors.white,
        ),
        onPressed: () {
          ref.read(drawStateProvider.notifier).setActiveDraw(draw).then(
              (value) => Get.toNamed(AppRoutes.promotionalDrawEditScreen));
        },
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.blue)),
      ),
    );
  }

  Widget viewButton(PromotionalDraw draw) {
    return Container(
      margin: const EdgeInsets.only(left: 2, right: 2),
      child: ElevatedButton(
        child: const Icon(
          Icons.remove_red_eye_outlined,
          color: Colors.black,
        ),
        onPressed: () {
          ref.read(drawStateProvider.notifier).setActiveDraw(draw).then(
              (value) => Get.toNamed(AppRoutes.promotionalDrawViewScreen));
        },
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.white)),
      ),
    );
  }

  Widget deleteButton(PromotionalDraw draw) {
    return Container(
      margin: const EdgeInsets.only(left: 2, right: 2),
      child: ElevatedButton(
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
        onPressed: () {
          ref.read(drawStateProvider.notifier).deletePromotionalDraw(draw);
        },
        style:
            ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
      ),
    );
  }

  Widget filterMenu() {
    return Row(
      children: [
        const Text("Filter by plan: "),
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
                    "FREE",
                    textAlign: TextAlign.center,
                  ),
                  value: "free",
                ),
                DropdownMenuItem(
                  child: Text(
                    "PRO",
                    textAlign: TextAlign.center,
                  ),
                  value: "pro",
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
    var drawProvider = ref.read(drawStateProvider.notifier);
    drawProvider.initPromotionalDraws();
  }

  @override
  Widget build(BuildContext context) {
    const double _responsiveWidth = 1500;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: NavigationWidget(
          activePage: "Promotional Draw",
          actions: [
            filterMenu(),
            const SizedBox(
              width: 30,
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.archive),
              label: Text(_filterClosed ? "View Open" : "View Archive"),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              onPressed: () {
                setState(() {
                  _filterClosed = !_filterClosed;
                  _pageIndex = 0;
                });
              },
            ),
            const SizedBox(
              width: 30,
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Create New draw"),
              onPressed: () {
                ref.read(drawStateProvider.notifier).setActiveDraw(null);
                Get.toNamed(AppRoutes.promotionalDrawEditScreen);
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
                dataReady: !ref.watch(drawStateProvider).isLoading,
                dataColumns: const [
                  'Draw Name',
                  'FREE / PRO',
                  'Status',
                  'Capacity',
                  'Draw Date',
                  "Action"
                ],
                lastVal: ref.watch(drawStateProvider).dataRange.toString(),
                dataRows: ref
                    .watch(drawStateProvider)
                    .fetchPaginatedDrawList(
                        searchTerm: _searchTerm,
                        filter: _filterTerm,
                        filterClosed: _filterClosed)
                    .map((draw) {
                  return DataRow(cells: [
                    DataCell(Text(draw.name)),
                    DataCell(Text(draw.drawType)),
                    DataCell(Text(draw.drawStatus)),
                    DataCell(Text(draw.ticketsSold.toString() +
                        " / " +
                        draw.totalTicketsIssued.toString())),
                    DataCell(Text(draw.drawDate != null
                        ? format.format(draw.drawDate!)
                        : "Unknown")),
                    DataCell(Row(
                      children: [
                        if (draw.drawStatus == "open") editButton(draw),
                        viewButton(draw),
                        if (draw.drawStatus == "open" && draw.tickets.isEmpty)
                          deleteButton(draw)
                      ],
                    ))
                  ]);
                }).toList(),
              ))),
    );
  }
}
