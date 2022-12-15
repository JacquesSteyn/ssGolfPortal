import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartgolfportal/state/notes/note.model.dart';

import '../../services/db_service.dart';

final DBService _dbService = DBService();

class NoteStateModel extends ChangeNotifier {
  List<Note> notes;
  bool initSet;
  bool isLoading;
  int dataRange;

  NoteStateModel(
      {this.notes = const [],
      this.initSet = false,
      this.dataRange = 0,
      this.isLoading = false});

  initNotes() async {
    if (initSet == false) {
      isLoading = true;
      notifyListeners();

      List<Note> notes = await _dbService.fetchNotes();

      this.notes = notes;
      isLoading = false;
      initSet = true;
      notifyListeners();
    }
  }

  Future<List<Note>> fetchAllNotes() async {
    if (notes.isEmpty) {
      List<Note> notes = await _dbService.fetchNotes();
      this.notes = notes;
      initSet = true;
      notifyListeners();
      return Future.value(notes);
    } else {
      return Future.value(notes);
    }
  }

  List<Note> fetchPaginatedNoteList({String? action, String? searchTerm}) {
    List<Note> notes = [...this.notes];

    if (searchTerm != null && searchTerm.isNotEmpty) {
      notes = notes
          .where((note) =>
              note.title.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
    }

    if (action == "plus") {
      dataRange = dataRange + 10;
    } else if (action == "minus") {
      dataRange = dataRange - 10;
    }
    int toRange =
        (dataRange + 11 > notes.length) ? notes.length : dataRange + 11;
    if (notes.isNotEmpty) {
      if (dataRange > notes.length) {
        dataRange = 0;
      }
      return notes.getRange(dataRange, toRange).toList();
    }
    return [];
  }

  Future<void> createNewNote(Note note) async {
    await _dbService.createNewNote(note);
    notes.add(note);
    notifyListeners();
  }

  Future<void> updateNote(Note oldNote, Note note) async {
    Note newNote = await _dbService.updateNote(note);
    int index = notes.indexOf(oldNote);
    notes[index] = newNote;
    notifyListeners();
  }

  void deleteNote(Note note) {
    int index = notes.indexOf(note);
    _dbService.deleteNote(note);

    notes.removeAt(index);
    notifyListeners();
  }

  void deleteNoteOption(Note note, String option) {
    int index = notes.indexOf(note);
    int elementIndex = notes[index].options.indexOf(option);

    _dbService.deleteNoteOption(note, elementIndex.toString());

    notes[index].options.removeAt(elementIndex);
    notifyListeners();
  }
}

final noteStateProvider = ChangeNotifierProvider(((ref) => NoteStateModel()));
