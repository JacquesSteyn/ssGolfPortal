import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:smartgolfportal/state/feedback/models/feedback.model.dart';
import 'package:smartgolfportal/state/physical/physical.state.dart';

import '../state/golf/golf.state.dart';
import '../widgets/navigation.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  @override
  Widget build(BuildContext context) {
    String notifier =
        (ModalRoute.of(context)?.settings.arguments ?? "") as String;

    if (notifier.isEmpty) {
      return Container();
    }

    List<AppFeedback?> provider = [];
    if (notifier == "golfStateProvider") {
      provider = ref.watch(golfStateProvider).currentFeedback;
    } else {
      provider = ref.watch(physicalStateProvider).currentFeedback;
    }

    return Scaffold(
      body: NavigationWidget(
        activePage: "",
        showSearchBar: false,
        actions: [
          ElevatedButton.icon(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.black),
            ),
            icon: const Icon(Icons.arrow_back),
            label: const Text("Back"),
            onPressed: () => {Get.back()},
          )
        ],
        child: LayoutBuilder(builder: (context, constraints) {
          return Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    columnSpacing: 5,
                    headingRowColor:
                        MaterialStateProperty.all(Get.theme.primaryColor),
                    columns: const [
                      DataColumn(
                        label: Flexible(
                          child: Text(
                            "Rating",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                decoration: TextDecoration.underline),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Flexible(
                          child: Text(
                            "Notes",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                decoration: TextDecoration.underline),
                          ),
                        ),
                      )
                    ],
                    rows: provider
                        .map(
                          (e) => DataRow(
                            cells: [
                              DataCell(RatingBar.builder(
                                  initialRating: e?.rating.toDouble() ?? 0,
                                  allowHalfRating: true,
                                  ignoreGestures: true,
                                  itemSize: 25,
                                  itemBuilder: (context, _) => const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                  onRatingUpdate: (val) => {})),
                              DataCell(
                                Text(
                                  (e?.ratingNotes != null &&
                                          e!.ratingNotes.isNotEmpty)
                                      ? e.ratingNotes
                                      : "No notes",
                                ),
                              )
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
