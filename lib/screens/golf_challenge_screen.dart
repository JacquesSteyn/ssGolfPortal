import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:smartgolfportal/edit_widgets/edit_benchmark_inputs.dart';
import 'package:smartgolfportal/router.dart';
import 'package:smartgolfportal/services/db_service.dart';
import 'package:smartgolfportal/state/golf/golf.state.dart';
import 'package:smartgolfportal/state/golf/models/golf.model.dart';
import 'package:smartgolfportal/state/golf/models/skill.model.dart';
import 'package:smartgolfportal/state/shared_models/benchmark.model.dart';
import 'package:smartgolfportal/widgets/data_table.dart';
import 'package:smartgolfportal/widgets/navigation.dart';

class GolfChallengeScreen extends ConsumerStatefulWidget {
  const GolfChallengeScreen({Key? key}) : super(key: key);

  @override
  _GolfChallengeScreenState createState() => _GolfChallengeScreenState();
}

class _GolfChallengeScreenState extends ConsumerState<GolfChallengeScreen> {
  int _pageIndex = 0;
  List<GolfChallenge> _challenges = [];
  String _searchTerm = "";
  String _filterTerm = "all";
  Benchmark? overAllPhysicalBenchmarks;

  void setPrevious(String firstVal) {
    setState(() {
      if (_pageIndex > 0) {
        _pageIndex--;
      }
      _challenges = ref
          .read(golfStateProvider)
          .fetchPaginatedChallengeList(action: "minus");
    });
  }

  void setNext(String lastVal) {
    setState(() {
      _pageIndex++;
      _challenges = ref
          .read(golfStateProvider)
          .fetchPaginatedChallengeList(action: "plus");
    });
  }

  void toggleStatus(GolfChallenge challenge) {
    ref.read(golfStateProvider).toggleGolfChallenge(challenge);
  }

  Widget editButton(GolfChallenge challenge) {
    return ElevatedButton(
      child: const Icon(
        Icons.edit,
        color: Colors.black,
      ),
      onPressed: () {
        ref
            .read(golfStateProvider.notifier)
            .setActiveChallenge(challenge)
            .then((value) => Get.toNamed(AppRoutes.golfEditScreen));
      },
      style:
          ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
    );
  }

  Widget filterMenu() {
    List<Skill> skills = ref.read(golfStateProvider).golfSkills;

    return Row(
      children: [
        const Text("Filter by skill: "),
        FutureBuilder(builder: ((context, snapshot) {
          return DropdownButton(
              value: _filterTerm,
              alignment: Alignment.center,
              items: [
                const DropdownMenuItem(
                  child: Text(
                    "All",
                    textAlign: TextAlign.center,
                  ),
                  value: "all",
                ),
                ...skills
                    .map((skill) => DropdownMenuItem(
                          child: Text(
                            skill.name,
                            textAlign: TextAlign.center,
                          ),
                          value: skill.id,
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

  void showPhysicalBenchmarkPopup() {
    Benchmark overallBenchmark =
        ref.read(golfStateProvider).overallPhysicalBenchmark ??
            Benchmark.empty();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Overall Physical Benchmarks"),
        content: SizedBox(
          width: Get.width * 0.5,
          height: Get.height * 0.25,
          child: SingleChildScrollView(
            child: BenchmarkInputs(
              benchmarks: overallBenchmark,
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              ref
                  .read(golfStateProvider)
                  .updateGolfOverallPhysicalBenchmarks(overallBenchmark);
              Get.back();
            },
            child: const Text("Save"),
          )
        ],
      ),
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
    var golfProvider = ref.read(golfStateProvider.notifier);
    golfProvider.initGolfChallenges();
    overAllPhysicalBenchmarks = golfProvider.overallPhysicalBenchmark;
  }

  @override
  Widget build(BuildContext context) {
    const double _responsiveWidth = 1500;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: NavigationWidget(
          activePage: "Golf Challenges",
          actions: [
            filterMenu(),
            const SizedBox(
              width: 30,
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_chart_sharp),
              label: const Text("Physical Benchmarks"),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              onPressed: () {
                showPhysicalBenchmarkPopup();
              },
            ),
            const SizedBox(
              width: 30,
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("New Challenge"),
              onPressed: () {
                ref.read(golfStateProvider.notifier).setActiveChallenge(null);
                Get.toNamed(AppRoutes.golfEditScreen);
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
                dataReady: !ref.watch(golfStateProvider).isLoading,
                dataColumns: [
                  'Name',
                  'Type',
                  'Skill',
                  'Description',
                  'Status',
                  'Video',
                  screenWidth > _responsiveWidth ? 'Difficulty' : "",
                  'Total\n Completions',
                  'Total\n Feedback',
                  ""
                ],
                lastVal: ref.watch(golfStateProvider).dataRange.toString(),
                dataRows: ref
                    .watch(golfStateProvider)
                    .fetchPaginatedChallengeList(
                        searchTerm: _searchTerm, filter: _filterTerm)
                    .map((challenge) {
                  return DataRow(cells: [
                    DataCell(Text(challenge.name)),
                    DataCell(Text(challenge.type)),
                    DataCell(
                      Text(ref
                              .watch(golfStateProvider)
                              .fetchChallengeSkill(challenge.skillIdElementId)
                              ?.name ??
                          ""),
                    ),
                    DataCell(Text(challenge.description)),
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
                      screenWidth > _responsiveWidth
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
                      future:
                          DBService().fetchChallengeResultsCount(challenge.id),
                      builder: (context, snapshot) =>
                          Text(snapshot.data ?? "0"),
                    ))),
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
                                        ref
                                            .read(golfStateProvider)
                                            .setActiveFeedback(challenge.id)
                                            .then((value) => {
                                                  Get.toNamed(
                                                      AppRoutes.feedbackScreen,
                                                      arguments:
                                                          "golfStateProvider")
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
              ))),
    );
  }
}
