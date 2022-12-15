import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:smartgolfportal/state/notes/note.model.dart';
import 'package:smartgolfportal/state/notes/note.state.dart';
import 'package:smartgolfportal/widgets/data_table.dart';
import 'package:smartgolfportal/widgets/navigation.dart';

import '../widgets/custom_input.dart';
import '../widgets/input_popup.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  int _pageIndex = 0;
  List<Note> _notes = [];
  String _searchTerm = "";
  List<String> _noteOptionsEditList = [];

  void setPrevious(String firstVal) {
    setState(() {
      if (_pageIndex > 0) {
        _pageIndex--;
      }
      _notes =
          ref.read(noteStateProvider).fetchPaginatedNoteList(action: "minus");
    });
  }

  void setNext(String lastVal) {
    setState(() {
      _pageIndex++;
      _notes =
          ref.read(noteStateProvider).fetchPaginatedNoteList(action: "plus");
    });
  }

  Widget editButton(Note note) {
    return ElevatedButton(
      child: const Icon(
        Icons.edit,
        color: Colors.black,
      ),
      onPressed: () => showEditNote(note),
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

  createNote(Note note) {
    ref.read(noteStateProvider).createNewNote(note).then((value) => Get.back());
  }

  updateNote(Note oldNote, Note note) {
    ref
        .read(noteStateProvider)
        .updateNote(oldNote, note)
        .then((value) => Get.back());
  }

  Widget deleteOptionButton(Note note, String option) {
    return ElevatedButton(
      child: const Icon(
        Icons.delete,
        color: Colors.black,
      ),
      onPressed: () {
        ref.read(noteStateProvider).deleteNoteOption(note, option);
        Get.back();
      },
      style:
          ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
    );
  }

  showAddNote() {
    return showDialog(
        context: context,
        builder: (_) {
          final TextEditingController noteTitle = TextEditingController();

          final _formKey = GlobalKey<FormState>();

          return Form(
            key: _formKey,
            child: InputPopup(
              title: "Edit Note",
              action: () {
                if (_formKey.currentState!.validate()) {
                  Note newNote = Note.init(
                    title: noteTitle.text,
                  );
                  createNote(newNote);
                }
              },
              widthScale: 0.2,
              inputFields: [
                Wrap(
                  children: [
                    CustomInput(
                      controller: noteTitle,
                      title: "Note Title*",
                      width: 300,
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  showAddOption(Note note) {
    return showDialog(
        context: context,
        builder: (_) {
          final TextEditingController option = TextEditingController();

          final _formKey = GlobalKey<FormState>();

          return Form(
            key: _formKey,
            child: InputPopup(
                title: "Create Note Option",
                action: () {
                  if (_formKey.currentState!.validate()) {
                    Note oldNote = note;
                    note.options.add(option.text);

                    updateNote(oldNote, note);
                  }
                },
                widthScale: 0.2,
                inputFields: [
                  CustomInput(
                    controller: option,
                    title: "Option Title*",
                  ),
                ]),
          );
        });
  }

  showEditNote(Note note) {
    return showDialog(
        context: context,
        builder: (_) {
          final TextEditingController noteTitle = TextEditingController();

          noteTitle.text = note.title;

          _noteOptionsEditList = note.options;

          final _formKey = GlobalKey<FormState>();

          return Form(
            key: _formKey,
            child: InputPopup(
              title: "Edit Note",
              action: () {
                if (_formKey.currentState!.validate()) {
                  Note newNote = Note.init(
                      title: noteTitle.text,
                      id: note.id,
                      options: _noteOptionsEditList);
                  updateNote(note, newNote);
                }
              },
              widthScale: 0.5,
              inputFields: [
                Wrap(
                  children: [
                    CustomInput(
                      controller: noteTitle,
                      title: "Note Title*",
                      width: 300,
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
                              "Options",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            )),
                        Wrap(
                          children: [
                            ...note.options.map(
                              (option) {
                                if (option != "null") {
                                  TextEditingController optionController =
                                      TextEditingController();
                                  optionController.text = option;
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CustomInput(
                                        title: "Option Title*",
                                        controller: optionController,
                                        onChange: (String val) {
                                          if (val.isNotEmpty) {
                                            int index = _noteOptionsEditList
                                                .indexOf(option);
                                            _noteOptionsEditList[index] = val;
                                          }
                                        },
                                      ),
                                      deleteOptionButton(note, option)
                                    ],
                                  );
                                } else {
                                  return const SizedBox();
                                }
                              },
                            ).toList(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget deleteNoteButton(Note note) {
    return ElevatedButton(
      child: const Icon(
        Icons.delete,
        color: Colors.red,
      ),
      onPressed: () => {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Delete Note"),
            content: const Text("Are you sure you want to delete it?"),
            actions: [
              TextButton(
                  onPressed: () => Get.back(), child: const Text("Cancel")),
              TextButton(
                onPressed: () {
                  ref.read(noteStateProvider).deleteNote(note);
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
    var noteProvider = ref.read(noteStateProvider.notifier);
    noteProvider.initNotes();
  }

  @override
  Widget build(BuildContext context) {
    var noteProvider = ref.watch(noteStateProvider);

    return Scaffold(
      body: NavigationWidget(
          activePage: "Notes",
          actions: [
            ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("New Note"),
                onPressed: () => showAddNote())
          ],
          searchFunction: setSearchTerm,
          child: SingleChildScrollView(
              controller: ScrollController(),
              child: CustomDataTable(
                pageIndex: _pageIndex,
                onPrevious: (firstVal) => setPrevious(firstVal),
                onNext: (lastVal) => setNext(lastVal),
                dataReady: !noteProvider.isLoading,
                dataColumns: const ['Title', 'Options', ""],
                lastVal: noteProvider.dataRange.toString(),
                dataRows: noteProvider
                    .fetchPaginatedNoteList(searchTerm: _searchTerm)
                    .map((note) {
                  return DataRow(cells: [
                    DataCell(Text(note.title)),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          children: [
                            ...note.options.map((option) {
                              if (option != "null") {
                                return Card(
                                    color: Colors.blue.shade200,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(option),
                                    ));
                              } else {
                                return const SizedBox();
                              }
                            }).toList(),
                            GestureDetector(
                              onTap: () => showAddOption(note),
                              child: const Card(
                                  color: Colors.blue,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      "Add Option",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )),
                            )
                          ],
                        ),
                      ),
                    ),
                    DataCell(Wrap(
                      spacing: 10,
                      children: [editButton(note), deleteNoteButton(note)],
                    ))
                  ]);
                }).toList(),
              ))),
    );
  }
}
