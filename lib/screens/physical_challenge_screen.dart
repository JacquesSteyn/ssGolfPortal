import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:smartgolfportal/services/db_service.dart';
import 'package:smartgolfportal/state/physical/models/attribute.model.dart';
import 'package:smartgolfportal/state/physical/models/physical.model.dart';
import 'package:smartgolfportal/state/physical/physical.state.dart';
import 'package:smartgolfportal/widgets/data_table.dart';
import 'package:smartgolfportal/widgets/navigation.dart';

import '../router.dart';

class PhysicalChallengeScreen extends ConsumerStatefulWidget {
  const PhysicalChallengeScreen({Key? key}) : super(key: key);

  @override
  _PhysicalChallengeScreenState createState() =>
      _PhysicalChallengeScreenState();
}

class _PhysicalChallengeScreenState
    extends ConsumerState<PhysicalChallengeScreen> {
  int _pageIndex = 0;
  List<PhysicalChallenge> _challenges = [];
  String _searchTerm = "";
  String _filterTerm = "all";

  void setPrevious(String firstVal) {
    setState(() {
      if (_pageIndex > 0) {
        _pageIndex--;
      }
      _challenges = ref
          .read(physicalStateProvider)
          .fetchPaginatedChallengeList(action: "minus");
    });
  }

  void setNext(String lastVal) {
    setState(() {
      _pageIndex++;
      _challenges = ref
          .read(physicalStateProvider)
          .fetchPaginatedChallengeList(action: "plus");
    });
  }

  void toggleStatus(PhysicalChallenge challenge) {
    ref.read(physicalStateProvider).togglePhysicalChallenge(challenge);
  }

  Widget editButton(PhysicalChallenge challenge) {
    return ElevatedButton(
      onPressed: () {
        ref
            .read(physicalStateProvider.notifier)
            .setActiveChallenge(challenge)
            .then((value) => Get.toNamed(AppRoutes.physicalEditScreen));
      },
      style:
          ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
      child: const Icon(
        Icons.edit,
        color: Colors.black,
      ),
    );
  }

  Widget filterMenu(List<Attribute> attributes) {
    return Row(
      children: [
        const Text("Filter by attribute: "),
        FutureBuilder(builder: ((context, snapshot) {
          return DropdownButton(
              value: _filterTerm,
              alignment: Alignment.center,
              items: [
                const DropdownMenuItem(
                  value: "all",
                  child: Text(
                    "All",
                    textAlign: TextAlign.center,
                  ),
                ),
                ...attributes
                    .map((attribute) => DropdownMenuItem(
                          value: attribute.id,
                          child: Text(
                            attribute.name,
                            textAlign: TextAlign.center,
                          ),
                        ))
                    .toList()
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
    var physicalProvider = ref.read(physicalStateProvider.notifier);
    physicalProvider.initPhysicalChallenges();
  }

  @override
  Widget build(BuildContext context) {
    const double responsiveWidth = 1500;
    double screenWidth = MediaQuery.of(context).size.width;

    var physicalProvider = ref.watch(physicalStateProvider);

    return Scaffold(
      body: NavigationWidget(
          activePage: "Physical Challenges",
          actions: [
            filterMenu(physicalProvider.physicalAttributes),
            const SizedBox(
              width: 30,
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("New Challenge"),
              onPressed: () {
                ref
                    .read(physicalStateProvider.notifier)
                    .setActiveChallenge(null);
                Get.toNamed(AppRoutes.physicalEditScreen);
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
              dataReady: !physicalProvider.isLoading,
              rowHeight: 60,
              dataColumns: [
                'Name',
                'Attribute',
                'Description',
                'Status',
                'Video',
                screenWidth > responsiveWidth ? 'Difficulty' : "",
                'Total\n Completions',
                'Total\n Feedback',
                ""
              ],
              lastVal: physicalProvider.dataRange.toString(),
              dataRows: physicalProvider
                  .fetchPaginatedChallengeList(
                      searchTerm: _searchTerm, filter: _filterTerm)
                  .map((challenge) {
                return DataRow(cells: [
                  DataCell(Text(challenge.name)),
                  DataCell(
                    Text(physicalProvider
                            .fetchChallengeAttribute(challenge.attributeId)
                            ?.name ??
                        ""),
                  ),
                  DataCell(SizedBox(
                      width: Get.width * 0.2,
                      child: Text(
                        challenge.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ))),
                  DataCell(Switch(
                      value: challenge.status,
                      activeColor: Colors.black,
                      onChanged: (val) => toggleStatus(challenge))),
                  DataCell(
                    challenge.videoUrl.isNotEmpty
                        ? const Icon(Icons.check, color: Colors.green)
                        : const Icon(
                            Icons.close,
                            color: Colors.red,
                          ),
                  ),
                  DataCell(
                    screenWidth > responsiveWidth
                        ? RatingBar.builder(
                            initialRating: challenge.difficulty,
                            allowHalfRating: true,
                            ignoreGestures: true,
                            itemSize: 25,
                            itemBuilder: (context, _) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                            onRatingUpdate: (val) => {})
                        : Container(),
                  ),
                  DataCell(Center(
                      child: FutureBuilder<String>(
                          future: DBService()
                              .fetchChallengeResultsCount(challenge.id),
                          builder: (context, snapshot) {
                            String data = snapshot.data ?? "0";
                            if (data != "0") {
                              return InkWell(
                                onTap: () {
                                  Get.toNamed(AppRoutes.challengeResultScreen,
                                      arguments: {
                                        'challengeType': 'physical',
                                        'challengeId': challenge.id,
                                        'challengeName': challenge.name
                                      });
                                },
                                child: Text(data),
                              );
                            } else {
                              return Text(data);
                            }
                          }))),
                  DataCell(
                    Center(
                      child: FutureBuilder<String>(
                        future: DBService()
                            .fetchChallengeFeedbackCount(challenge.id),
                        builder: (context, snapshot) {
                          String count = snapshot.data ?? "0";
                          if (count == "0") {
                            return const Card(
                                elevation: 5,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("0"),
                                ));
                          } else {
                            return InkWell(
                                onTap: () => {
                                      physicalProvider
                                          .setActiveFeedback(challenge.id)
                                          .then((value) => {
                                                Get.toNamed(
                                                    AppRoutes.feedbackScreen,
                                                    arguments:
                                                        "physicalStateProvider")
                                              })
                                    },
                                child: Card(
                                    elevation: 5,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(count),
                                    )));
                          }
                        },
                      ),
                    ),
                  ),
                  DataCell(editButton(challenge))
                ]);
              }).toList(),
            ),
          )),
    );
  }
}
