import '../../shared_models/benchmark.model.dart';
import '../../shared_models/field_input.model.dart';
import '../../notes/note.model.dart';
import '../../shared_models/tip_group.model.dart';
import 'skill_element_weighting.model.dart';

class GolfChallenge {
  late String name;
  late String id;
  late String description;
  late String purpose;
  late String type;
  late double difficulty;
  late String duration;
  late String videoUrl;
  late String imageUrl;
  late List<String> equipment;
  late List<String> instructions;
  late List<TipGroup> tips;
  late SkillElementWeightings weightings;
  late List<FieldInput>
      fieldInputs; // selection(range/course) + int with max value + club selection
  late Benchmark benchmarks;
  late List<Note?> notes;

  late String weightingBandId;

  // for publishing to users
  late bool status;

  // for references
  late String skillIdElementId;

  GolfChallenge([input, key]) {
    try {
      name = input?['name'] ?? "";
      id = input?['id'] ?? key;
      description = input?['description'] ?? "";
      purpose = input?['purpose'] ?? "";
      type = input?['type'];
      difficulty = double.parse(input?['difficulty'] ?? "0");
      duration = input?['duration'] ?? "";
      videoUrl = input?['videoUrl'] ?? "";
      imageUrl = input?['imageUrl'] ?? "";
      equipment = input['equipment'] != null
          ? input['equipment'].map<String>((text) => text.toString()).toList()
          : [];
      instructions = input['instructions'] != null
          ? input['instructions']
              .map<String>((text) => text.toString())
              .toList()
          : [];
      tips = input?['tips'] != null
          ? (input?['tips'] as Iterable)
              .map((tipData) => TipGroup(tipData))
              .toList()
          : [];

      weightings = SkillElementWeightings(input?['weightings']);
      fieldInputs = input?['fieldInputs'] != null
          ? (input?['fieldInputs'] as Iterable)
              .map((inputData) => FieldInput(inputData))
              .toList()
          : [];

      weightingBandId = input?['weightingBandId'];
      benchmarks = Benchmark(input?['benchmarks']);

      status = input?['status'] ?? true;
      skillIdElementId = input?['skillIdElementId'] ?? "";

      notes = input?['notes'] != null
          ? (input?['notes'] as Iterable)
              .map((noteData) => Note(noteData))
              .toList()
          : [];
    } catch (e) {
      print("GOLF CHALLENGE MODEL ERROR: $e");
    }
  }

  GolfChallenge.init({
    required this.name,
    required this.id,
    required this.description,
    required this.purpose,
    required this.type,
    required this.difficulty,
    required this.duration,
    required this.videoUrl,
    required this.imageUrl,
    required this.equipment,
    required this.instructions,
    required this.tips,
    required this.weightings,
    required this.fieldInputs,
    required this.weightingBandId,
    required this.benchmarks,
    required this.status,
    required this.skillIdElementId,
    required this.notes,
  });

  getJson() {
    return {
      'name': name,
      'id': id,
      'description': description,
      'purpose': purpose,
      'type': type,
      'difficulty': difficulty.toString(),
      'duration': duration,
      'videoUrl': videoUrl,
      'imageUrl': imageUrl,
      'equipment': equipment,
      'instructions': instructions,
      'tips': tips.map((tip) => tip.getJson()),
      'weightings': weightings.getJson(),
      'fieldInputs': fieldInputs.map((fieldInput) => fieldInput.getJson()),
      'benchmarks': benchmarks.getJson(),
      'weightingBandId': weightingBandId,
      'status': status,
      'skillIdElementId': skillIdElementId,
      'notes': notes.map((note) => note?.getJson()),
    };
  }
}
