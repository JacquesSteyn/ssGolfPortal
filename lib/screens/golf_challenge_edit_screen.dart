import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:smartgolfportal/edit_widgets/edit_benchmark_inputs.dart';
import 'package:smartgolfportal/edit_widgets/edit_equipment_inputs.dart';
import 'package:smartgolfportal/edit_widgets/edit_input_fields.dart';
import 'package:smartgolfportal/edit_widgets/edit_instruction_inputs.dart';
import 'package:smartgolfportal/edit_widgets/edit_tip_inputs.dart';
import 'package:smartgolfportal/state/bands/band.state.dart';
import 'package:smartgolfportal/state/bands/models/weighting_bands.model.dart';
import 'package:smartgolfportal/state/golf/golf.state.dart';
import 'package:smartgolfportal/state/golf/models/element_weighting.model.dart';
import 'package:smartgolfportal/state/golf/models/golf.model.dart';
import 'package:smartgolfportal/state/notes/note.model.dart';
import 'package:smartgolfportal/state/notes/note.state.dart';
import 'package:smartgolfportal/widgets/custom_text_field.dart';

import '../edit_widgets/edit_media_inputs.dart';
import '../state/golf/models/skill.model.dart';
import '../state/golf/models/skill_element_weighting.model.dart';
import '../state/shared_models/benchmark.model.dart';
import '../state/shared_models/field_input.model.dart';
import '../state/shared_models/tip_group.model.dart';
import '../widgets/navigation.dart';

class GolfEditScreen extends ConsumerStatefulWidget {
  const GolfEditScreen({Key? key}) : super(key: key);

  @override
  _GolfEditScreenState createState() => _GolfEditScreenState();
}

class _GolfEditScreenState extends ConsumerState<GolfEditScreen> {
  int _stepIndex = 0;
  bool isLoading = true;
  bool newChallenge = true;
  GolfChallenge? oldChallenge;

  final GlobalKey<FormState> _golfChallengeFormKey = GlobalKey<FormState>();

  //inputs
  late String name = "";
  late String id = "";
  late String description = "";
  late String purpose = "";
  late String type = 'range';
  late double difficulty = 0;
  late String duration = "";
  late String videoUrl = "";
  late String imageUrl = "";
  late List<String> equipment = [];
  late List<String> instructions = [];
  late List<TipGroup> tips = [];
  late SkillElementWeightings weightings = SkillElementWeightings.empty();
  late Skill? selectedSkill;
  late String weightingBandId = "";
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

  Widget radioType() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Title(
            color: Colors.black,
            child: const Text("Golf Type",
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: 150,
                child: ListTile(
                  title: const Text('Range'),
                  leading: Radio(
                    value: 'range',
                    groupValue: type,
                    onChanged: (val) {
                      setState(() {
                        type = val.toString();
                      });
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 150,
                child: ListTile(
                  title: const Text('Course'),
                  leading: Radio(
                    value: 'course',
                    groupValue: type,
                    onChanged: (val) {
                      setState(() {
                        type = val.toString();
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget skillWeightingsInputs() {
    return FutureBuilder(
      future: ref.read(golfStateProvider.notifier).fetchAllSkills(),
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          List<Skill> parentSkills = snapshot.data as List<Skill>;

          String defOption = "";
          if (weightings.skillId.isNotEmpty) {
            defOption = weightings.skillId;
          } else {
            defOption = parentSkills.isNotEmpty ? parentSkills.first.id : "";
          }

          selectedSkill = parentSkills.firstWhere(
              (element) => element.id == defOption,
              orElse: () => Skill());
          weightings.skillId = selectedSkill?.id ?? "";
          weightings.skill = selectedSkill?.name ?? "";
          weightings.elementId = biggestElementID;

          List<ElementWeighting> tempWeightings = [...weightings.weightings];

          return Row(
            children: [
              Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Title(
                        color: Colors.black,
                        child: const Text("Parent Skill",
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
                        value: weightings.skillId.isEmpty
                            ? defOption
                            : weightings.skillId,
                        alignment: Alignment.center,
                        items: parentSkills
                            .map((skill) => DropdownMenuItem(
                                  child: Text(
                                    skill.name,
                                    textAlign: TextAlign.center,
                                  ),
                                  value: skill.id,
                                ))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            weightings.skillId = val.toString();
                            selectedSkill = parentSkills.firstWhere(
                                (element) => element.id == val.toString(),
                                orElse: () => Skill());
                            weightings.skill = selectedSkill!.name;
                          });
                        },
                      ),
                    ),
                    if (selectedSkill != null)
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
                                    spacing: 10,
                                    runSpacing: 10,
                                    children:
                                        selectedSkill!.elements.map((element) {
                                      tempWeightings.add(ElementWeighting.init(
                                        element: element,
                                        weight: weightings.weightings.isNotEmpty
                                            ? weightings
                                                .weightings[element.id].weight
                                            : 0,
                                      ));

                                      return CustomTextField(
                                        element.id.toString() ==
                                                biggestElementID
                                            ? element.name + " (Biggest)"
                                            : element.name,
                                        (val) {
                                          tempWeightings[element.id].weight =
                                              int.parse(val);
                                          weightings.weightings =
                                              tempWeightings;
                                        },
                                        onlyNumbers: true,
                                        width: 100,
                                        onChange: (val) {
                                          tempWeightings[element.id].weight =
                                              int.parse(val);
                                          weightings.weightings =
                                              tempWeightings;
                                          weightings.elementId =
                                              getBiggestElementValID();
                                        },
                                        initialValue:
                                            weightings.weightings.isNotEmpty
                                                ? weightings
                                                    .weightings[element.id]
                                                    .weight
                                                    .toString()
                                                : null,
                                      );
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
            children: const [
              CircularProgressIndicator(),
            ],
          );
        }
      }),
    );
  }

  Widget weightBandInput() => FutureBuilder(
      future: ref.read(bandStateProvider.notifier).fetchAllBands(),
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          List<WeightingBands> bands = (snapshot.data != null)
              ? snapshot.data as List<WeightingBands>
              : [];
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
                    value: weightingBandId,
                    alignment: Alignment.center,
                    items: [
                      const DropdownMenuItem(
                        child: Text(
                          "Select band",
                          textAlign: TextAlign.center,
                        ),
                        value: "",
                      ),
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

  String getBiggestElementValID() {
    int biggestWeight = 0;
    String elementID = "0";
    for (var mainWeight in weightings.weightings) {
      if (mainWeight.weight > biggestWeight) {
        biggestWeight = mainWeight.weight;
        elementID = mainWeight.element.id.toString();
      }
    }

    biggestElementID = elementID;

    return elementID;
  }

  saveChallenge() {
    if (_golfChallengeFormKey.currentState!.validate()) {
      String combinedID = selectedSkill?.id.toString() ?? "0";
      combinedID += biggestElementID.toString();
      GolfChallenge challenge = GolfChallenge.init(
          name: name,
          id: id,
          description: description,
          purpose: purpose,
          type: type,
          difficulty: difficulty,
          duration: duration,
          videoUrl: videoUrl,
          imageUrl: imageUrl,
          equipment: equipment,
          instructions: instructions,
          tips: tips,
          weightings: weightings,
          fieldInputs: fieldInputs,
          weightingBandId: weightingBandId,
          benchmarks: benchmarks,
          status: true,
          skillIdElementId: combinedID,
          notes: selectedNotes);

      if (newChallenge) {
        ref
            .read(golfStateProvider.notifier)
            .createNewChallenge(challenge)
            .then((value) {
          Get.back();
        });
      } else {
        ref
            .read(golfStateProvider.notifier)
            .updateGolfChallenge(oldChallenge, challenge)
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
    GolfChallenge? challenge = ref.read(golfStateProvider).activeChallenge;

    if (challenge != null) {
      name = challenge.name;
      id = challenge.id;
      description = challenge.description;
      purpose = challenge.purpose;
      type = challenge.type;
      difficulty = challenge.difficulty;
      duration = challenge.duration;
      videoUrl = challenge.videoUrl;
      imageUrl = challenge.imageUrl;
      equipment = challenge.equipment;
      instructions = challenge.instructions;
      tips = challenge.tips;
      weightings = challenge.weightings;
      weightingBandId = challenge.weightingBandId;
      fieldInputs = challenge.fieldInputs;
      selectedNotes = challenge.notes;
      benchmarks = challenge.benchmarks;
      selectedSkill = null;
      biggestElementID = getBiggestElementValID();

      newChallenge = false;
      oldChallenge = challenge;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: NavigationWidget(
        activePage: "Golf Challenges",
        titleOverride: "New Golf Challenge",
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
              key: _golfChallengeFormKey,
              child: Stepper(
                  currentStep: _stepIndex,
                  type: StepperType.horizontal,
                  physics: const ClampingScrollPhysics(),
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
                              radioType(),
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
                              skillWeightingsInputs(),
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
            if (ref.read(golfStateProvider).isLoading)
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
