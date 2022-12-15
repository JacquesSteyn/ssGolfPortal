import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import 'package:smartgolfportal/state/golf/models/element.model.dart';
import 'package:smartgolfportal/state/golf/models/skill.model.dart';
import 'package:smartgolfportal/state/physical/models/attribute.model.dart';
import 'package:smartgolfportal/state/shared_models/benchmark.model.dart';
import 'package:smartgolfportal/widgets/custom_input.dart';
import 'package:smartgolfportal/widgets/input_popup.dart';
import 'package:smartgolfportal/widgets/navigation.dart';

import '../state/golf/golf.state.dart';

class SkillElementScreen extends ConsumerStatefulWidget {
  const SkillElementScreen({
    Key? key,
  }) : super(key: key);

  @override
  _SkillElementScreenState createState() => _SkillElementScreenState();
}

class _SkillElementScreenState extends ConsumerState<SkillElementScreen> {
  List<SkillElement> _skillElementEditList = [];

  Widget headingText(String label) => Container(
        height: 40,
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              decoration: TextDecoration.underline),
        ),
      );

  List<TableRow> dataRows(List<Skill> skills) {
    List<TableRow> rows = [];
    List<Attribute> attributes = ref.read(golfStateProvider).golfAttributes;

    for (Skill skill in skills) {
      rows.add(TableRow(
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300, width: 2))),
          children: [
            const SizedBox(
              width: 10,
            ),
            TableCell(
                child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(skill.index.toString()),
            )),
            TableCell(
                child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(skill.name),
            )),
            TableCell(
                child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.centerLeft,
              child: Wrap(children: [
                Card(
                  color: Colors.grey.shade200,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Pro (${skill.benchmarks.pro})"),
                  ),
                ),
                Card(
                  color: Colors.grey.shade200,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("0 - 9 (${skill.benchmarks.zero_to_nine})"),
                  ),
                ),
                Card(
                  color: Colors.grey.shade200,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                        Text("10 - 19 (${skill.benchmarks.ten_to_nineteen})"),
                  ),
                ),
                Card(
                  color: Colors.grey.shade200,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        "20 - 29 (${skill.benchmarks.twenty_to_twenty_nine})"),
                  ),
                ),
                Card(
                  color: Colors.grey.shade200,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("30+ (${skill.benchmarks.thirty_plus})"),
                  ),
                ),
              ]),
            )),
            TableCell(
                child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.centerLeft,
              child: Wrap(
                children: [
                  ...skill.elements
                      .map((element) => Card(
                          color: Colors.blue.shade200,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("${element.name} - ${element.weight}%"),
                          )))
                      .toList(),
                  GestureDetector(
                    onTap: () => showAddElement(skill),
                    child: const Card(
                        color: Colors.blue,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Add Element",
                            style: TextStyle(color: Colors.white),
                          ),
                        )),
                  )
                ],
              ),
            )),
            TableCell(
                child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.centerLeft,
              child: Wrap(
                children: [
                  ...skill.attributes
                      .map((attribute) => Card(
                          color: Colors.green.shade200,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(attribute.name),
                          )))
                      .toList(),
                  GestureDetector(
                    onTap: () => showEditSkillAttribute(attributes, skill),
                    child: Card(
                        color: Colors.green.shade800,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Edit Attribute",
                            style: TextStyle(color: Colors.white),
                          ),
                        )),
                  )
                ],
              ),
            )),
            TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Wrap(
                  runSpacing: 10,
                  children: [editButton(skill), deleteSkillButton(skill)],
                )),
            const SizedBox(
              width: 10,
            ),
          ]));
    }

    return rows;
  }

  Widget editButton(Skill skill) {
    return ElevatedButton(
      child: const Icon(
        Icons.edit,
        color: Colors.black,
      ),
      onPressed: () => showEditSkill(skill),
      style:
          ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
    );
  }

  Widget deleteSkillButton(Skill skill) {
    return ElevatedButton(
      child: const Icon(
        Icons.delete,
        color: Colors.red,
      ),
      onPressed: () => {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Delete Skill"),
            content: const Text("Are you sure you want to delete it?"),
            actions: [
              TextButton(
                  onPressed: () => Get.back(), child: const Text("Cancel")),
              TextButton(
                onPressed: () {
                  ref.read(golfStateProvider).deleteSkill(skill);
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

  Widget deleteElementButton(Skill skill, SkillElement element) {
    return ElevatedButton(
      child: const Icon(
        Icons.delete,
        color: Colors.red,
      ),
      onPressed: () {
        ref.read(golfStateProvider).deleteSkillElement(skill, element);
        Get.back();
      },
      style:
          ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
    );
  }

  createSkill(Skill skill) {
    ref
        .read(golfStateProvider)
        .createNewSkill(skill)
        .then((value) => Get.back());
  }

  updateSkill(Skill oldSkill, Skill skill) {
    ref
        .read(golfStateProvider)
        .updateSkill(oldSkill, skill)
        .then((value) => Get.back());
  }

  showEditSkillAttribute(List<Attribute> attributes, Skill skill) {
    return showDialog(
        context: context,
        builder: (_) {
          final oldSkill = skill;
          final _items = attributes
              .map((e) => MultiSelectItem<Attribute?>(
                  Attribute.init(name: e.name, weight: e.weight, id: e.id),
                  e.name))
              .toList();

          List<Attribute?> _selectedAttributes = [];

          for (int i = 0; i < _items.length; i++) {
            if (skill.attributes
                .map((item) => item.name)
                .contains(_items[i].label)) {
              _items[i].selected = true;
              var item = _items[i];
              _selectedAttributes.add(item.value);
            }
          }

          return MultiSelectDialog<Attribute?>(
            listType: MultiSelectListType.CHIP,
            items: _items,
            initialValue: _selectedAttributes,
            cancelText: const Text("Cancel"),
            confirmText: const Text("Save"),
            onConfirm: (value) {
              List<Attribute> att = [];
              for (var element in value) {
                att.add(Attribute.init(
                    name: element?.name ?? "",
                    weight: element?.weight ?? 0,
                    id: element?.id ?? "0"));
              }
              skill.attributes = att;
              ref.read(golfStateProvider).updateSkill(oldSkill, skill);
            },
          );
        });
  }

  showAddSkill() {
    return showDialog(
        context: context,
        builder: (_) {
          final TextEditingController skillName = TextEditingController();
          final TextEditingController skillIndex = TextEditingController();

          final TextEditingController benchPro = TextEditingController();
          final TextEditingController benchToNine = TextEditingController();
          final TextEditingController benchToNineteen = TextEditingController();
          final TextEditingController benchToTwentyNine =
              TextEditingController();
          final TextEditingController benchThirtyPlus = TextEditingController();

          String skillIcon = "";

          final _formKey = GlobalKey<FormState>();

          return Form(
            key: _formKey,
            child: InputPopup(
                title: "Create Skill",
                action: () {
                  if (_formKey.currentState!.validate()) {
                    Skill skill = Skill.init(
                        name: skillName.text,
                        iconName: skillIcon,
                        index: int.parse(skillIndex.text),
                        benchmarks: Benchmark.init(
                            pro: benchPro.text,
                            zero_to_nine: benchToNine.text,
                            ten_to_nineteen: benchToNineteen.text,
                            twenty_to_twenty_nine: benchToTwentyNine.text,
                            thirty_plus: benchThirtyPlus.text),
                        elements: [],
                        attributes: []);
                    createSkill(skill);
                  }
                },
                widthScale: 0.5,
                inputFields: [
                  Wrap(
                    children: [
                      CustomInput(controller: skillName, title: "Skill Name*"),
                      CustomInput(
                        controller: skillIndex,
                        title: "Skill Index*",
                        onlyNumbers: true,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Skill Icon*",
                              style: TextStyle(fontSize: 14),
                            ),
                            Container(
                              width: 250,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(10)),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: DropdownButtonFormField(
                                decoration: const InputDecoration(
                                    border: InputBorder.none),
                                value: skillIcon,
                                items: const [
                                  DropdownMenuItem(
                                    child: Text("Select Icon"),
                                    value: "",
                                  ),
                                  DropdownMenuItem(
                                    child: Text("Putter"),
                                    value: "putter_icon",
                                  ),
                                  DropdownMenuItem(
                                    child: Text("Wedge"),
                                    value: "wedge_icon",
                                  ),
                                  DropdownMenuItem(
                                    child: Text("Driver"),
                                    value: "driver_icon",
                                  ),
                                  DropdownMenuItem(
                                    child: Text("Iron"),
                                    value: "iron_icon",
                                  ),
                                ],
                                onChanged: (val) {
                                  skillIcon = val.toString();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Card(
                    margin: const EdgeInsets.all(20),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Title(
                              color: Colors.black,
                              child: const Text(
                                "Benchmarks",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              )),
                          Row(
                            children: [
                              CustomInput(
                                title: "Pro",
                                controller: benchPro,
                                expanded: true,
                                onlyNumbers: true,
                              ),
                              CustomInput(
                                title: "0-9",
                                controller: benchToNine,
                                expanded: true,
                                onlyNumbers: true,
                              ),
                              CustomInput(
                                title: "10-19",
                                controller: benchToNineteen,
                                expanded: true,
                                onlyNumbers: true,
                              ),
                              CustomInput(
                                title: "20-29",
                                controller: benchToTwentyNine,
                                expanded: true,
                                onlyNumbers: true,
                              ),
                              CustomInput(
                                title: "30+",
                                controller: benchThirtyPlus,
                                expanded: true,
                                onlyNumbers: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
          );
        });
  }

  showEditSkill(Skill skill) {
    return showDialog(
        context: context,
        builder: (_) {
          final TextEditingController skillName = TextEditingController();
          final TextEditingController skillIndex = TextEditingController();

          final TextEditingController benchPro = TextEditingController();
          final TextEditingController benchToNine = TextEditingController();
          final TextEditingController benchToNineteen = TextEditingController();
          final TextEditingController benchToTwentyNine =
              TextEditingController();
          final TextEditingController benchThirtyPlus = TextEditingController();

          skillName.text = skill.name;
          skillIndex.text = skill.index.toString();
          benchPro.text = skill.benchmarks.pro.toString();
          benchToNine.text = skill.benchmarks.zero_to_nine.toString();
          benchToNineteen.text = skill.benchmarks.ten_to_nineteen.toString();
          benchToTwentyNine.text =
              skill.benchmarks.twenty_to_twenty_nine.toString();
          benchThirtyPlus.text = skill.benchmarks.thirty_plus.toString();

          String skillIcon = skill.iconName;

          _skillElementEditList = skill.elements;

          final _formKey = GlobalKey<FormState>();

          return Form(
            key: _formKey,
            child: InputPopup(
                title: "Edit Skill",
                action: () {
                  if (_formKey.currentState!.validate()) {
                    Skill newSkill = Skill.init(
                        name: skillName.text,
                        iconName: skillIcon,
                        id: skill.id,
                        index: int.parse(skillIndex.text),
                        benchmarks: Benchmark.init(
                            pro: benchPro.text,
                            zero_to_nine: benchToNine.text,
                            ten_to_nineteen: benchToNineteen.text,
                            twenty_to_twenty_nine: benchToTwentyNine.text,
                            thirty_plus: benchThirtyPlus.text),
                        elements: _skillElementEditList,
                        attributes: skill.attributes);
                    updateSkill(skill, newSkill);
                  }
                },
                widthScale: 0.5,
                inputFields: [
                  Wrap(
                    children: [
                      CustomInput(controller: skillName, title: "Skill Name*"),
                      CustomInput(
                          controller: skillIndex,
                          title: "Skill Index*",
                          onlyNumbers: true),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Skill Icon*",
                              style: TextStyle(fontSize: 14),
                            ),
                            Container(
                              width: 250,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(10)),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: DropdownButtonFormField(
                                decoration: const InputDecoration(
                                    border: InputBorder.none),
                                value: skillIcon,
                                items: const [
                                  DropdownMenuItem(
                                    child: Text("Putter"),
                                    value: "putter_icon",
                                  ),
                                  DropdownMenuItem(
                                    child: Text("Wedge"),
                                    value: "wedge_icon",
                                  ),
                                  DropdownMenuItem(
                                    child: Text("Driver"),
                                    value: "driver_icon",
                                  ),
                                  DropdownMenuItem(
                                    child: Text("Iron"),
                                    value: "iron_icon",
                                  ),
                                ],
                                onChanged: (val) {
                                  skillIcon = val.toString();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Card(
                    margin: const EdgeInsets.all(20),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Title(
                              color: Colors.black,
                              child: const Text(
                                "Benchmarks",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              )),
                          Row(
                            children: [
                              CustomInput(
                                title: "Pro",
                                controller: benchPro,
                                expanded: true,
                                onlyNumbers: true,
                              ),
                              CustomInput(
                                title: "0-9",
                                controller: benchToNine,
                                expanded: true,
                                onlyNumbers: true,
                              ),
                              CustomInput(
                                title: "10-19",
                                controller: benchToNineteen,
                                expanded: true,
                                onlyNumbers: true,
                              ),
                              CustomInput(
                                title: "20-29",
                                controller: benchToTwentyNine,
                                expanded: true,
                                onlyNumbers: true,
                              ),
                              CustomInput(
                                title: "30+",
                                controller: benchThirtyPlus,
                                expanded: true,
                                onlyNumbers: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.all(20),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Title(
                              color: Colors.black,
                              child: const Text(
                                "Elements",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              )),
                          ...skill.elements
                              .map((element) => skillElement(skill, element))
                              .toList()
                        ],
                      ),
                    ),
                  ),
                ]),
          );
        });
  }

  showAddElement(Skill skill) {
    return showDialog(
        context: context,
        builder: (_) {
          final TextEditingController elementName = TextEditingController();
          final TextEditingController elementWeight = TextEditingController();

          final _formKey = GlobalKey<FormState>();

          return Form(
            key: _formKey,
            child: InputPopup(
                title: "Create Skill",
                action: () {
                  if (_formKey.currentState!.validate()) {
                    Skill oldSkill = skill;

                    SkillElement element = SkillElement.init(
                        name: elementName.text,
                        weight: double.parse(elementWeight.text),
                        id: skill.elements.length);
                    skill.elements.add(element);
                    updateSkill(oldSkill, skill);
                  }
                },
                widthScale: 0.5,
                inputFields: [
                  Wrap(
                    children: [
                      CustomInput(
                          controller: elementName, title: "Skill Name*"),
                      CustomInput(
                        controller: elementWeight,
                        title: "Skill Index*",
                        onlyNumbers: true,
                      ),
                    ],
                  ),
                ]),
          );
        });
  }

  Widget skillElement(Skill skill, SkillElement element) {
    TextEditingController elementName = TextEditingController();
    TextEditingController elementWeight = TextEditingController();

    elementName.text = element.name;
    elementWeight.text = element.weight.toString();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomInput(
              title: "Name*",
              controller: elementName,
              expanded: true,
              onChange: (val) {
                int index = _skillElementEditList.indexOf(element);
                _skillElementEditList[index].name = val;
              },
            ),
            CustomInput(
              title: "Weight*",
              controller: elementWeight,
              expanded: true,
              onChange: (String val) {
                int index = _skillElementEditList.indexOf(element);
                _skillElementEditList[index].weight =
                    val.isEmpty ? 0 : double.parse(val);
              },
            ),
            deleteElementButton(skill, element)
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    var golfProvider = ref.read(golfStateProvider.notifier);
    golfProvider.initGolfChallenges();
  }

  @override
  Widget build(BuildContext context) {
    var provider = ref.watch(golfStateProvider);

    return Scaffold(
      body: NavigationWidget(
        activePage: "Skills & Elements",
        showSearchBar: false,
        actions: [
          ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("New Skill"),
              onPressed: () => showAddSkill())
        ],
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Table(
            columnWidths: const <int, TableColumnWidth>{
              0: FixedColumnWidth(10),
              1: FixedColumnWidth(45),
              2: FlexColumnWidth(),
              3: FlexColumnWidth(),
              4: FlexColumnWidth(),
              5: FlexColumnWidth(),
              6: FixedColumnWidth(80),
              7: FixedColumnWidth(10),
            },
            children: [
              TableRow(
                  decoration: const BoxDecoration(color: Colors.black),
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    TableCell(child: headingText('Index')),
                    TableCell(child: headingText("Name")),
                    TableCell(child: headingText("Benchmark")),
                    TableCell(child: headingText("Elements")),
                    TableCell(child: headingText("Attributes")),
                    TableCell(child: Container()),
                    const SizedBox(
                      width: 10,
                    ),
                  ]),
              ...dataRows(provider.golfSkills),
            ],
          ),
        ),
      ),
    );
  }
}
