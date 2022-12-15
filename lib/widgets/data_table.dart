import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomDataTable extends StatelessWidget {
  const CustomDataTable(
      {Key? key,
      required this.dataColumns,
      required this.dataRows,
      required this.dataReady,
      required this.onNext,
      required this.onPrevious,
      required this.pageIndex,
      this.firstVal = "",
      this.lastVal = "",
      this.rowHeight = 56})
      : super(key: key);

  final List<String> dataColumns;
  final List<DataRow> dataRows;
  final bool dataReady;
  final Function onNext;
  final Function onPrevious;
  final String firstVal;
  final String lastVal;
  final int pageIndex;
  final double rowHeight;

  DataColumn customColumn(String label) => DataColumn(
        label: Flexible(
          child: Text(
            label,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                decoration: TextDecoration.underline),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: ((context, constraints) {
        if (!dataReady) {
          return const Padding(
              padding: EdgeInsets.only(top: 30),
              child: Center(
                child: Text("Data Loading..."),
              ));
        } else if (dataRows.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 30),
            child: Center(
              child: Text("No Data"),
            ),
          );
        } else {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: ScrollController(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minWidth: constraints.maxWidth,
                      maxHeight: constraints.maxHeight),
                  child: DataTable(
                    columnSpacing: 5,
                    dataRowHeight: rowHeight,
                    headingRowColor:
                        MaterialStateProperty.all(Get.theme.primaryColor),
                    columns: dataColumns
                        .map((label) => customColumn(label))
                        .toList(),
                    rows: dataRows.map((row) => row).toList(),
                  ),
                ),
              ),
              Center(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  if (pageIndex > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ElevatedButton(
                        child: const Text("<<"),
                        onPressed: () => onPrevious(firstVal),
                      ),
                    ),
                  if (dataRows.length > 10)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ElevatedButton(
                        child: const Text(">>"),
                        onPressed: () => onNext(lastVal),
                      ),
                    )
                ]),
              ),
            ],
          );
        }
      }),
    );
  }
}
