import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:smartgolfportal/state/physical/models/attribute.model.dart';
import 'package:smartgolfportal/state/physical/models/physical.model.dart';
import 'package:smartgolfportal/state/physical/physical.state.dart';
import 'package:smartgolfportal/widgets/custom_input.dart';
import 'package:smartgolfportal/widgets/data_table.dart';
import 'package:smartgolfportal/widgets/navigation.dart';

import '../widgets/input_popup.dart';

class AttributesScreen extends ConsumerStatefulWidget {
  const AttributesScreen({Key? key}) : super(key: key);

  @override
  _AttributesScreenState createState() => _AttributesScreenState();
}

class _AttributesScreenState extends ConsumerState<AttributesScreen> {
  int _pageIndex = 0;
  List<Attribute> _challenges = [];

  void setPrevious(String firstVal) {
    setState(() {
      if (_pageIndex > 0) {
        _pageIndex--;
      }
      _challenges = ref
          .read(physicalStateProvider)
          .fetchPaginatedAttributeList(action: "minus");
    });
  }

  void setNext(String lastVal) {
    setState(() {
      _pageIndex++;
      _challenges = ref
          .read(physicalStateProvider)
          .fetchPaginatedAttributeList(action: "plus");
    });
  }

  void toggleStatus(PhysicalChallenge challenge) {
    ref.read(physicalStateProvider).togglePhysicalChallenge(challenge);
  }

  Widget editButton(Attribute att) {
    return ElevatedButton(
      child: const Icon(
        Icons.edit,
        color: Colors.black,
      ),
      onPressed: () => showEditAttribute(att),
      style:
          ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
    );
  }

  Widget deleteButton(Attribute att) {
    return ElevatedButton(
      child: const Icon(
        Icons.delete,
        color: Colors.red,
      ),
      onPressed: () => {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Delete Attribute"),
            content: const Text("Are you sure you want to delete it?"),
            actions: [
              TextButton(
                  onPressed: () => Get.back(), child: const Text("Cancel")),
              TextButton(
                onPressed: () {
                  ref.read(physicalStateProvider).deleteAttribute(att);
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

  createAttribute(Attribute att) {
    ref
        .read(physicalStateProvider)
        .createNewAttribute(att)
        .then((value) => Get.back());
  }

  showAddAttribute() {
    return showDialog(
        context: context,
        builder: (_) {
          final TextEditingController atbName = TextEditingController();
          final TextEditingController atbWeight = TextEditingController();

          final _formKey = GlobalKey<FormState>();

          return Form(
            key: _formKey,
            child: InputPopup(
                title: "Create Attribute",
                action: () {
                  if (_formKey.currentState!.validate()) {
                    Attribute att = Attribute.init(
                        name: atbName.text,
                        weight: double.parse(atbWeight.text));
                    createAttribute(att);
                  } else {}
                },
                inputFields: [
                  Wrap(
                    children: [
                      CustomInput(
                        controller: atbName,
                        title: "Attribute Name*",
                        width: 300,
                      ),
                      CustomInput(
                        controller: atbWeight,
                        title: "Attribute wight*",
                        onlyNumbers: true,
                      )
                    ],
                  ),
                ]),
          );
        });
  }

  updateAttribute(Attribute oldAttribute, Attribute att) {
    ref
        .read(physicalStateProvider)
        .updateAttribute(oldAttribute, att)
        .then((value) => Get.back());
  }

  showEditAttribute(Attribute attribute) {
    return showDialog(
        context: context,
        builder: (_) {
          final TextEditingController atbName = TextEditingController();
          final TextEditingController atbWeight = TextEditingController();

          atbName.text = attribute.name;
          atbWeight.text = attribute.weight.toString();

          final _formKey = GlobalKey<FormState>();

          return Form(
            key: _formKey,
            child: InputPopup(
                title: "Create Attribute",
                action: () {
                  if (_formKey.currentState!.validate()) {
                    Attribute newAtt = Attribute.init(
                        name: atbName.text,
                        id: attribute.id,
                        weight: double.parse(atbWeight.text));
                    updateAttribute(attribute, newAtt);
                  } else {}
                },
                inputFields: [
                  Wrap(
                    children: [
                      CustomInput(
                        controller: atbName,
                        title: "Attribute Name*",
                        width: 300,
                      ),
                      CustomInput(
                        controller: atbWeight,
                        title: "Attribute wight*",
                        onlyNumbers: true,
                      )
                    ],
                  ),
                ]),
          );
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
    var physicalProvider = ref.watch(physicalStateProvider);

    return Scaffold(
      body: NavigationWidget(
          activePage: "Attributes",
          showSearchBar: false,
          actions: [
            ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("New Attribute"),
                onPressed: () => showAddAttribute())
          ],
          child: CustomDataTable(
            pageIndex: _pageIndex,
            onPrevious: (firstVal) => setPrevious(firstVal),
            onNext: (lastVal) => setNext(lastVal),
            dataReady: !physicalProvider.isLoading,
            rowHeight: 60,
            dataColumns: const ['Name', 'Weight', ""],
            lastVal: physicalProvider.dataRange.toString(),
            dataRows:
                physicalProvider.fetchPaginatedAttributeList().map((attribute) {
              return DataRow(cells: [
                DataCell(Text(attribute.name)),
                DataCell(Text(attribute.weight.toString())),
                DataCell(Wrap(
                  runSpacing: 10,
                  spacing: 10,
                  children: [editButton(attribute), deleteButton(attribute)],
                ))
              ]);
            }).toList(),
          )),
    );
  }
}
