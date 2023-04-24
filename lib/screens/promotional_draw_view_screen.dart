import 'dart:convert';
import 'dart:html' as html;

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smartgolfportal/state/draws/models/draw.model.dart';
import 'package:smartgolfportal/widgets/custom_text_field.dart';

import '../state/draws/draw.state.dart';
import '../state/user/models/user.model.dart';
import '../widgets/navigation.dart';

class PromotionalDrawViewScreen extends StatelessWidget {
  PromotionalDrawViewScreen({Key? key}) : super(key: key);

  final customDate = DateFormat.yMMMEd();
  final customTime = DateFormat.Hm();

  List<List<dynamic>> ticketData = [];

  void generateCSV() {
    if (ticketData.isNotEmpty) {
      // we will declare the list of headers that we want
      List<String> rowHeader = [
        "Ticket_No",
        "Name",
        "Email",
        "Ticket_Date",
        "Gender",
        "Age",
        "Plan"
      ];

      List<List<dynamic>> rows = [];

      //First add entire row header into our first row
      rows.add(rowHeader);
      for (var row in ticketData) {
        rows.add(row);
      }
//now convert our 2d array into the csv list using the plugin of csv
      String csv = const ListToCsvConverter().convert(rows);
//this csv variable holds entire csv data
//Now Convert or encode this csv string into utf8
      final bytes = utf8.encode(csv);
//NOTE THAT HERE WE USED HTML PACKAGE
      final blob = html.Blob([bytes]);
//It will create downloadable object
      final url = html.Url.createObjectUrlFromBlob(blob);
//It will create anchor to download the file
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = 'user_tickets.csv';
//finally add the csv anchor to body
      html.document.body!.children.add(anchor);
// Cause download by calling this function
      anchor.click();
//revoke the object
      html.Url.revokeObjectUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NavigationWidget(
        activePage: "Promotional Draw",
        titleOverride: "Promotional Draw Info",
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
          PromotionalDraw? draw = ref.read(drawStateProvider).activeDraw;
          if (draw == null) {
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
                          "Draw Entries",
                          () => null,
                          initialValue:
                              "${draw.ticketsSold}/${draw.totalTicketsIssued}",
                          readOnly: true,
                          width: Get.width * 0.2,
                        ),
                        CustomTextField(
                          "Draw Date",
                          () => null,
                          initialValue: customDate.format(draw.drawDate!),
                          readOnly: true,
                          width: Get.width * 0.2,
                        ),
                        CustomTextField(
                          "Draw Time",
                          () => null,
                          initialValue: customTime.format(draw.drawDate!),
                          readOnly: true,
                          width: Get.width * 0.2,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        const Text(
                          "Entry List",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ElevatedButton.icon(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.blue)),
                            icon: const Icon(
                              Icons.exit_to_app,
                              color: Colors.white,
                            ),
                            label: const Text("Export CSV"),
                            onPressed: () => generateCSV()),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    FutureBuilder(
                      future: ref
                          .read(drawStateProvider.notifier)
                          .fetchTicketUsers(draw),
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
                                          "Ticket No",
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
                                          "Date Entered",
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
                                          "Gender",
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
                                          "Age",
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
                                  rows: draw.tickets.map((ticket) {
                                    User? ticketUser = userData[ticket.userID];
                                    if (ticketUser != null) {
                                      List rowData = [
                                        ticket.id,
                                        ticketUser.name ?? "Unknown",
                                        ticketUser.email ?? "Unknown",
                                        customDate.format(ticket.purchaseDate),
                                        ticketUser.gender ?? "Unknown",
                                        ticketUser.getAge() ?? "Unknown",
                                        ticketUser.plan ?? "Unknown"
                                      ];
                                      ticketData.add(rowData);
                                    }
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                            draw.drawWinnerID == ticketUser?.id
                                                ? Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.military_tech,
                                                        color: Colors.yellow,
                                                      ),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(ticket.id)
                                                    ],
                                                  )
                                                : Text(ticket.id)),
                                        DataCell(
                                          Text(ticketUser?.name ?? "Unknown"),
                                        ),
                                        DataCell(
                                          Text(ticketUser?.email ?? "Unknown"),
                                        ),
                                        DataCell(Text(customDate
                                            .format(ticket.purchaseDate))),
                                        DataCell(Text(
                                            ticketUser?.gender ?? "Unknown")),
                                        DataCell(Text(
                                            ticketUser?.getAge() ?? "Unknown")),
                                        DataCell(Text(
                                            ticketUser?.plan ?? "Unknown")),
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
