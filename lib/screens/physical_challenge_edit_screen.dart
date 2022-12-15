import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:smartgolfportal/edit_widgets/edit_benchmark_inputs.dart';
import 'package:smartgolfportal/edit_widgets/edit_equipment_inputs.dart';
import 'package:smartgolfportal/edit_widgets/edit_input_fields.dart';
import 'package:smartgolfportal/edit_widgets/edit_instruction_inputs.dart';
import 'package:smartgolfportal/edit_widgets/edit_media_inputs.dart';
import 'package:smartgolfportal/edit_widgets/edit_tip_inputs.dart';
import 'package:smartgolfportal/state/bands/band.state.dart';
import 'package:smartgolfportal/state/bands/models/weighting_bands.model.dart';
import 'package:smartgolfportal/state/notes/note.model.dart';
import 'package:smartgolfportal/state/notes/note.state.dart';
import 'package:smartgolfportal/state/physical/models/attribute.model.dart';
import 'package:smartgolfportal/state/physical/models/attribute_weightings.model.dart';
import 'package:smartgolfportal/widgets/custom_text_field.dart';

import '../state/physical/models/attribute_weighting.model.dart';
import '../state/physical/models/physical.model.dart';
import '../state/physical/physical.state.dart';
import '../state/shared_models/benchmark.model.dart';
import '../state/shared_models/field_input.model.dart';
import '../state/shared_models/tip_group.model.dart';
import '../widgets/navigation.dart';

class PhysicalEditScreen extends ConsumerStatefulWidget {
  const PhysicalEditScreen({Key? key}) : super(key: key);

  @override
  _PhysicalEditScreenState createState() => _PhysicalEditScreenState();
}

class _PhysicalEditScreenState extends ConsumerState<PhysicalEditScreen> {
  int _stepIndex = 0;
  bool isLoading = true;
  bool newChallenge = true;
  PhysicalChallenge? oldChallenge;

  final GlobalKey<FormState> _physicalChallengeFormKey = GlobalKey<FormState>();

  //inputs
  late String name = "";
  late String id = "";
  late String description = "";
  late String purpose = "";
  late double difficulty = 0;
  late String duration = "";
  late String videoUrl = "";
  late String imageUrl = "";
  late List<String> equipment = [];
  late List<String> instructions = [];
  late List<TipGroup> tips = [];
  late AttributeWeightings weightings = AttributeWeightings.empty();
  late Attribute? selectedAttribute;
  late String weightingBandId = "";
  late String attributeId = "";
  late List<FieldInput> fieldInputs = [];
  late List<Note?> selectedNotes = [];
  late Benchmark benchmarks = Benchmark.empty();

  String biggestElementID = "0";

  ////
  ///

  Widget difficultyField() => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Title(
              color: Colors.black,
              child: const Text("Difficulty Rating",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          const SizedBox(
            height: 5,
          ),
          Container(
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 20),
              child: RatingBar.builder(
                  initialRating: difficulty,
                  allowHalfRating: true,
                  itemSize: 25,
                  itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                  onRatingUpdate: (val) => difficulty = val)),
        ],
      );

  Widget attributeWeightingsInputs() {
    return FutureBuilder(
        future: ref.read(physicalStateProvider).fetchAllAttributes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            List<AttributeWeighting> tempWeightings = [
              ...weightings.weightings
            ];

            List<Attribute> allAttributes = snapshot.data as List<Attribute>;

            int idCount = 0;
            if (weightings.weightings.isEmpty) {
              for (Attribute att in allAttributes) {
                tempWeightings.add(AttributeWeighting.init(
                    attribute: att, weight: 0, id: idCount));
                idCount++;
              }
            }
            //initial set
            weightings = AttributeWeightings.init(
                attribute: getBiggestAttributeVal(allAttributes),
                weightings: tempWeightings);

            return Row(
              children: [
                Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("Weightings",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                width: Get.width * 0.7,
                                child: Wrap(
                                    spacing: 20,
                                    runSpacing: 20,
                                    children: tempWeightings
                                        .map((attributeWeighting) {
                                      int attIndex = tempWeightings
                                          .indexOf(attributeWeighting);

                                      return CustomTextField(
                                          attributeWeighting
                                                      .attribute.id ==
                                                  biggestElementID
                                              ? attributeWeighting
                                                      .attribute.name +
                                                  " (Biggest)"
                                              : attributeWeighting
                                                  .attribute.name,
                                          (val) {
                                            tempWeightings[attIndex].weight =
                                                int.parse(val);
                                            weightings.weightings =
                                                tempWeightings;
                                          },
                                          onlyNumbers: true,
                                          width: 100,
                                          onChange: (val) {
                                            tempWeightings[attIndex].weight =
                                                int.parse(val);
                                            weightings.weightings =
                                                tempWeightings;
                                            attributeId =
                                                getBiggestAttributeVal(
                                                        allAttributes)
                                                    .id;
                                            weightings.attribute =
                                                getBiggestAttributeVal(
                                                    allAttributes);
                                          },
                                          initialValue: tempWeightings[attIndex]
                                              .weight
                                              .toString());
                                    }).toList()),
                              ),
                            ],
                          ),
                        ),
                      )
                    ]),
              ],
            );
          } else {
            return Row(
              children: const [CircularProgressIndicator()],
            );
          }
        });
  }

  Widget weightBandInput() => FutureBuilder(
      future: ref.read(bandStateProvider.notifier).fetchAllBands(),
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          List<WeightingBands> bands = (snapshot.data != null)
              ? snapshot.data as List<WeightingBands>
              : [];

          String initial =
              weightingBandId.isEmpty ? bands.first.id : weightingBandId;

          return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Title(
                    color: Colors.black,
                    child: const Text("Weight Band",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold))),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  key: UniqueKey(),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  margin: const EdgeInsets.only(bottom: 20),
                  child: DropdownButton(
                    value: initial,
                    alignment: Alignment.center,
                    items: [
                      ...bands
                          .map((band) => DropdownMenuItem(
                                child: Text(
                                  band.name,
                                  textAlign: TextAlign.center,
                                ),
                                value: band.id,
                              ))
                          .toList()
                    ],
                    onChanged: (val) {
                      setState(() {
                        weightingBandId = val.toString();
                      });
                    },
                  ),
                ),
              ]);
        } else {
          return const CircularProgressIndicator();
        }
      }));

  Widget noteSelection() {
    return FutureBuilder(
        future: ref.read(noteStateProvider.notifier).fetchAllNotes(),
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            List<Note> allNotes = snapshot.data as List<Note>;
            final _items = allNotes
                .map(
                  (e) => MultiSelectItem<Note?>(
                      Note.init(title: e.title, id: e.id, options: e.options),
                      e.title),
                )
                .toList();

            List<Note?> _selectedNotes = [];

            for (int i = 0; i < _items.length; i++) {
              if (selectedNotes
                  .map((item) => item?.title)
                  .contains(_items[i].label)) {
                _items[i].selected = true;
                var item = _items[i];
                _selectedNotes.add(item.value);
              }
            }

            return MultiSelectChipField<Note?>(
              title: const Text("Notes"),
              decoration: const BoxDecoration(color: Colors.white),
              headerColor: Colors.white,
              items: _items,
              initialValue: _selectedNotes,
              onTap: (values) {
                selectedNotes = values;
              },
            );
          } else {
            return const CircularProgressIndicator();
          }
        }));
  }

  Attribute getBiggestAttributeVal(List<Attribute> attWeighting) {
    int biggestWeight = 0;
    Attribute attribute = attWeighting.first;
    for (var mainWeight in weightings.weightings) {
      if (mainWeight.weight > biggestWeight) {
        biggestWeight = mainWeight.weight;
        attribute = mainWeight.attribute;
      }
    }

    biggestElementID = attribute.id;

    return attribute;
  }

  saveChallenge() {
    if (_physicalChallengeFormKey.currentState!.validate()) {
      PhysicalChallenge challenge = PhysicalChallenge.init(
          name: name,
          id: id,
          description: description,
          purpose: purpose,
          difficulty: difficulty,
          duration: duration,
          videoUrl: videoUrl,
          imageUrl: imageUrl,
          equipment: equipment,
          instructions: instructions,
          tips: tips,
          attributeWeightings: weightings,
          fieldInputs: fieldInputs,
          weightingBandId: weightingBandId,
          benchmarks: benchmarks,
          status: true,
          attributeId: biggestElementID,
          notes: selectedNotes);

      if (newChallenge) {
        ref
            .read(physicalStateProvider.notifier)
            .createNewChallenge(challenge)
            .then((value) {
          Get.back();
        });
      } else {
        ref
            .read(physicalStateProvider.notifier)
            .updatePhysicalChallenge(oldChallenge, challenge)
            .then((value) {
          Get.back();
        });
      }
    } else {
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                title: Text("Not all required fields are filled"),
              ));
    }
  }

  @override
  void initState() {
    super.initState();
    PhysicalChallenge? challenge =
        ref.read(physicalStateProvider).activeChallenge;

    selectedAttribute = null;

    if (challenge != null) {
      name = challenge.name;
      id = challenge.id;
      description = challenge.description;
      purpose = challenge.purpose;
      difficulty = challenge.difficulty;
      duration = challenge.duration;
      videoUrl = challenge.videoUrl;
      imageUrl = challenge.imageUrl;
      equipment = challenge.equipment;
      instructions = challenge.instructions;
      tips = challenge.tips;
      weightings = challenge.attributeWeightings;
      weightingBandId = challenge.weightingBandId;
      fieldInputs = challenge.fieldInputs;
      selectedNotes = challenge.notes;
      benchmarks = challenge.benchmarks;
      selectedAttribute = null;
      biggestElementID = "0";

      newChallenge = false;
      oldChallenge = challenge;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: NavigationWidget(
        activePage: "Physical Challenges",
        titleOverride: "New Physical Challenge",
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
          ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: Text(newChallenge ? "Create" : "Save"),
              onPressed: () => saveChallenge())
        ],
        child: Stack(
          children: [
            Form(
              key: _physicalChallengeFormKey,
              child: Stepper(
                  currentStep: _stepIndex,
                  type: StepperType.horizontal,
                  controlsBuilder: (_, details) => Row(
                        children: [
                          if (_stepIndex > 0)
                            ElevatedButton(
                                onPressed: details.onStepCancel,
                                child: const Text("Back")),
                          const SizedBox(
                            width: 10,
                          ),
                          if (_stepIndex != 6)
                            ElevatedButton(
                                onPressed: details.onStepContinue,
                                child: const Text("Continue"))
                          else
                            ElevatedButton(
                                onPressed: () => saveChallenge(),
                                child: const Text("Save")),
                        ],
                      ),
                  onStepCancel: () {
                    if (_stepIndex > 0) {
                      setState(() {
                        _stepIndex -= 1;
                      });
                    }
                  },
                  onStepContinue: () {
                    if (_stepIndex <= 6) {
                      setState(() {
                        _stepIndex += 1;
                      });
                    }
                  },
                  onStepTapped: (int index) {
                    setState(() {
                      _stepIndex = index;
                    });
                  },
                  steps: [
                    Step(
                      isActive: _stepIndex == 0,
                      title: const Text("Basics"),
                      content: Card(
                        elevation: 8,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextField(
                                "Name",
                                (val) => {name = val},
                                initialValue: name,
                                onChange: (val) => name = val,
                              ),
                              CustomTextField(
                                "Description",
                                (val) => {description = val},
                                initialValue: description,
                                onChange: (val) => description = val,
                              ),
                              CustomTextField(
                                "Purpose",
                                (val) => {purpose = val},
                                initialValue: purpose,
                                onChange: (val) => purpose = val,
                              ),
                              CustomTextField(
                                "Estimated Duration",
                                (val) => {duration = val},
                                initialValue: description,
                                onChange: (val) => duration = val,
                              ),
                              difficultyField()
                            ],
                          ),
                        ),
                      ),
                    ),
                    Step(
                      isActive: _stepIndex == 1,
                      title: const Text("Details"),
                      content: Card(
                        elevation: 8,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              EquipmentInputs(
                                equipment: equipment,
                              ),
                              InstructionInputs(
                                instructions: instructions,
                              ),
                              TipInputs(
                                tips: tips,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Step(
                      isActive: _stepIndex == 2,
                      title: const Text("Weighting"),
                      content: Card(
                        elevation: 8,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              attributeWeightingsInputs(),
                              weightBandInput()
                            ],
                          ),
                        ),
                      ),
                    ),
                    Step(
                      isActive: _stepIndex == 3,
                      title: const Text("Inputs"),
                      content: Card(
                        elevation: 8,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [InputField(fieldInputs: fieldInputs)],
                          ),
                        ),
                      ),
                    ),
                    Step(
                      isActive: _stepIndex == 4,
                      title: const Text("Media"),
                      content: Card(
                        elevation: 8,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MediaInputs(
                                imageURL: imageUrl,
                                videoURL: videoUrl,
                                updateImage: (val) {
                                  setState(() {
                                    imageUrl = val;
                                  });
                                },
                                updateVideo: (val) {
                                  setState(() {
                                    videoUrl = val;
                                  });
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Step(
                      isActive: _stepIndex == 5,
                      title: const Text("Notes"),
                      content: Card(
                        elevation: 8,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [noteSelection()],
                          ),
                        ),
                      ),
                    ),
                    Step(
                      isActive: _stepIndex == 6,
                      title: const Text("Benchmarks"),
                      content: Card(
                        elevation: 8,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [BenchmarkInputs(benchmarks: benchmarks)],
                          ),
                        ),
                      ),
                    ),
                  ]),
            ),
            if (ref.read(physicalStateProvider).isLoading)
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
    );
  }
}
