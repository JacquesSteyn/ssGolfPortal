import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:smartgolfportal/state/bands/band.state.dart';
import 'package:smartgolfportal/state/bands/models/weighting_band.model.dart';
import 'package:smartgolfportal/state/bands/models/weighting_bands.model.dart';
import 'package:smartgolfportal/widgets/custom_text_field.dart';

import 'package:smartgolfportal/widgets/data_table.dart';
import 'package:smartgolfportal/widgets/navigation.dart';

import '../widgets/custom_input.dart';
import '../widgets/input_popup.dart';

class WeightBandScreen extends ConsumerStatefulWidget {
  const WeightBandScreen({Key? key}) : super(key: key);

  @override
  _WeightBandScreenState createState() => _WeightBandScreenState();
}

class _WeightBandScreenState extends ConsumerState<WeightBandScreen> {
  int _pageIndex = 0;
  List<WeightingBands> _bands = [];
  String _searchTerm = "";

  void setPrevious(String firstVal) {
    setState(() {
      if (_pageIndex > 0) {
        _pageIndex--;
      }
      _bands = ref
          .read(bandStateProvider)
          .fetchPaginatedWeightingBandsList(action: "minus");
    });
  }

  void setNext(String lastVal) {
    setState(() {
      _pageIndex++;
      _bands = ref
          .read(bandStateProvider)
          .fetchPaginatedWeightingBandsList(action: "plus");
    });
  }

  Widget editButton(WeightingBands band) {
    return ElevatedButton(
      child: const Icon(
        Icons.edit,
        color: Colors.black,
      ),
      onPressed: () => showEditWeightingBands(band),
      style:
          ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
    );
  }

  void setSearchTerm(String? term) {
    setState(() {
      _searchTerm = term ?? "";
      _pageIndex = 0;
    });
  }

  createWeightingBands(WeightingBands band) {
    ref
        .read(bandStateProvider)
        .createNewWeightingBands(band)
        .then((value) => Get.back());
  }

  updateWeightingBands(WeightingBands oldWeightingBands, WeightingBands band) {
    ref
        .read(bandStateProvider)
        .updateWeightingBands(oldWeightingBands, band)
        .then((value) => Get.back());
  }

  Widget deleteOptionButton(WeightingBands band, WeightingBand option) {
    return ElevatedButton(
      child: const Icon(
        Icons.delete,
        color: Colors.red,
      ),
      onPressed: () {
        //ref.read(bandStateProvider).deleteWeightingBands(band, option);
        Get.back();
      },
      style:
          ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
    );
  }

  showAddWeightingBands() {
    List<WeightingBand> _bandOptionsEditList = [];
    return showDialog(
        context: context,
        builder: (_) {
          final TextEditingController bandTitle = TextEditingController();

          final _formKey = GlobalKey<FormState>();

          return Form(
            key: _formKey,
            child: InputPopup(
              title: "New Weighting Band",
              action: () {
                if (_formKey.currentState!.validate()) {
                  WeightingBands newWeightingBands = WeightingBands.init(
                      name: bandTitle.text, bands: _bandOptionsEditList);
                  createWeightingBands(newWeightingBands);
                }
              },
              widthScale: 0.5,
              inputFields: [
                StatefulBuilder(builder: (context, setState) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomInput(
                        controller: bandTitle,
                        title: "Weighting Bands Title*",
                        width: 300,
                      ),
                      Card(
                        elevation: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    "Bands",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _bandOptionsEditList
                                            .add(WeightingBand.empty());
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.add,
                                      color: Colors.blueAccent,
                                    ),
                                  )
                                ],
                              ),
                              ListView.builder(
                                  itemCount: _bandOptionsEditList.length,
                                  shrinkWrap: true,
                                  itemBuilder: (_, index) {
                                    WeightingBand element =
                                        _bandOptionsEditList[index];

                                    return Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black, width: 2),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      padding: const EdgeInsets.all(10.0),
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          CustomTextField(
                                              "Lower Range*",
                                              (val) {
                                                _bandOptionsEditList[index] =
                                                    val;
                                              },
                                              width: 100,
                                              onlyNumbers: true,
                                              initialValue:
                                                  element.lowerRange.toString(),
                                              onChange: (val) {
                                                _bandOptionsEditList[index]
                                                        .lowerRange =
                                                    int.parse(val);
                                              }),
                                          CustomTextField(
                                              "Upper Range*",
                                              (val) {
                                                _bandOptionsEditList[index] =
                                                    val;
                                              },
                                              width: 100,
                                              onlyNumbers: true,
                                              initialValue:
                                                  element.upperRange.toString(),
                                              onChange: (val) {
                                                _bandOptionsEditList[index]
                                                        .upperRange =
                                                    int.parse(val);
                                              }),
                                          CustomTextField(
                                              "Percentage*",
                                              (val) {
                                                _bandOptionsEditList[index] =
                                                    val;
                                              },
                                              width: 100,
                                              onlyNumbers: true,
                                              initialValue:
                                                  element.percentage.toString(),
                                              onChange: (val) {
                                                _bandOptionsEditList[index]
                                                        .percentage =
                                                    int.parse(val);
                                              }),
                                          CustomTextField(
                                              "Number of pref results*",
                                              (val) {
                                                _bandOptionsEditList[index] =
                                                    val;
                                              },
                                              width: 100,
                                              onlyNumbers: true,
                                              initialValue: element
                                                  .numberOfPreviousResults
                                                  .toString(),
                                              onChange: (val) {
                                                _bandOptionsEditList[index]
                                                        .numberOfPreviousResults =
                                                    int.parse(val);
                                              }),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _bandOptionsEditList
                                                    .removeAt(index);
                                              });
                                            },
                                            // tooltip: (element.isEmpty)
                                            //     ? "Delete equipment"
                                            //     : "Delete $element",
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  })
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          );
        });
  }

  showEditWeightingBands(WeightingBands oldBands) {
    List<WeightingBand> _bandOptionsEditList = oldBands.bands;

    return showDialog(
        context: context,
        builder: (_) {
          final TextEditingController bandTitle = TextEditingController();
          bandTitle.text = oldBands.name;

          final _formKey = GlobalKey<FormState>();

          return Form(
            key: _formKey,
            child: InputPopup(
              title: "New Weighting Band",
              action: () {
                if (_formKey.currentState!.validate()) {
                  WeightingBands newWeightingBands = WeightingBands.init(
                      id: oldBands.id,
                      name: bandTitle.text,
                      bands: _bandOptionsEditList);
                  updateWeightingBands(oldBands, newWeightingBands);
                }
              },
              widthScale: 0.5,
              inputFields: [
                StatefulBuilder(builder: (context, setState) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomInput(
                        controller: bandTitle,
                        title: "Weighting Bands Title*",
                        width: 300,
                      ),
                      Card(
                        elevation: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    "Bands",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _bandOptionsEditList
                                            .add(WeightingBand.empty());
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.add,
                                      color: Colors.blueAccent,
                                    ),
                                  )
                                ],
                              ),
                              ListView.builder(
                                  itemCount: _bandOptionsEditList.length,
                                  shrinkWrap: true,
                                  itemBuilder: (_, index) {
                                    WeightingBand element =
                                        _bandOptionsEditList[index];

                                    return Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black, width: 2),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      padding: const EdgeInsets.all(10.0),
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          CustomTextField(
                                              "Lower Range*",
                                              (val) {
                                                _bandOptionsEditList[index] =
                                                    val;
                                              },
                                              width: 100,
                                              onlyNumbers: true,
                                              initialValue:
                                                  element.lowerRange.toString(),
                                              onChange: (val) {
                                                _bandOptionsEditList[index]
                                                        .lowerRange =
                                                    int.parse(val);
                                              }),
                                          CustomTextField(
                                              "Upper Range*",
                                              (val) {
                                                _bandOptionsEditList[index] =
                                                    val;
                                              },
                                              width: 100,
                                              onlyNumbers: true,
                                              initialValue:
                                                  element.upperRange.toString(),
                                              onChange: (val) {
                                                _bandOptionsEditList[index]
                                                        .upperRange =
                                                    int.parse(val);
                                              }),
                                          CustomTextField(
                                              "Percentage*",
                                              (val) {
                                                _bandOptionsEditList[index] =
                                                    val;
                                              },
                                              width: 100,
                                              onlyNumbers: true,
                                              initialValue:
                                                  element.percentage.toString(),
                                              onChange: (val) {
                                                _bandOptionsEditList[index]
                                                        .percentage =
                                                    int.parse(val);
                                              }),
                                          CustomTextField(
                                              "Number of pref results*",
                                              (val) {
                                                _bandOptionsEditList[index] =
                                                    val;
                                              },
                                              width: 100,
                                              onlyNumbers: true,
                                              initialValue: element
                                                  .numberOfPreviousResults
                                                  .toString(),
                                              onChange: (val) {
                                                _bandOptionsEditList[index]
                                                        .numberOfPreviousResults =
                                                    int.parse(val);
                                              }),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _bandOptionsEditList
                                                    .removeAt(index);
                                              });
                                            },
                                            // tooltip: (element.isEmpty)
                                            //     ? "Delete equipment"
                                            //     : "Delete $element",
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  })
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          );
        });
  }

  Widget deleteWeightingBandsButton(WeightingBands band) {
    return ElevatedButton(
      child: const Icon(
        Icons.delete,
        color: Colors.red,
      ),
      onPressed: () => {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Delete WeightingBands"),
            content: const Text("Are you sure you want to delete it?"),
            actions: [
              TextButton(
                  onPressed: () => Get.back(), child: const Text("Cancel")),
              TextButton(
                onPressed: () {
                  ref.read(bandStateProvider).deleteWeightingBands(band);
                  Get.back();
                },
                child: const Text("Delete it"),
              )
            ],
          ),
        )
      },
      style:
          ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
    );
  }

  @override
  void initState() {
    super.initState();
    var bandProvider = ref.read(bandStateProvider.notifier);
    bandProvider.initBands();
  }

  @override
  Widget build(BuildContext context) {
    var bandProvider = ref.watch(bandStateProvider);

    return Scaffold(
      body: NavigationWidget(
          activePage: "Weighting Bands",
          actions: [
            ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("New Weighting Band"),
                onPressed: () => showAddWeightingBands())
          ],
          searchFunction: setSearchTerm,
          child: SingleChildScrollView(
              child: CustomDataTable(
            pageIndex: _pageIndex,
            onPrevious: (firstVal) => setPrevious(firstVal),
            onNext: (lastVal) => setNext(lastVal),
            dataReady: !bandProvider.isLoading,
            dataColumns: const ['Title', 'Bands', ""],
            lastVal: bandProvider.dataRange.toString(),
            dataRows: bandProvider
                .fetchPaginatedWeightingBandsList(searchTerm: _searchTerm)
                .map((band) {
              return DataRow(cells: [
                DataCell(Text(band.name)),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      children: [
                        ...band.bands.map((option) {
                          return Card(
                              color: Colors.blue.shade200,
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: RichText(
                                    text: TextSpan(children: [
                                      TextSpan(
                                          text:
                                              "${option.lowerRange} - ${option.upperRange} ",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      TextSpan(
                                          text: "( ${option.percentage}% )"),
                                    ]),
                                  )));
                        }).toList(),
                      ],
                    ),
                  ),
                ),
                DataCell(Wrap(
                  spacing: 10,
                  children: [
                    editButton(band),
                    deleteWeightingBandsButton(band)
                  ],
                ))
              ]);
            }).toList(),
          ))),
    );
  }
}
