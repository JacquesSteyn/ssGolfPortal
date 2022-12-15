import '../../shared_models/benchmark.model.dart';
import '../../shared_models/field_input.model.dart';
import '../../notes/note.model.dart';
import '../../shared_models/tip_group.model.dart';
import 'attribute_weightings.model.dart';

class PhysicalChallenge {
  // details
  late String name;
  late String id;
  late String description;
  late String purpose;
  late double difficulty;
  late String duration;
  late String videoUrl;
  late String imageUrl;
  late List<String> equipment;
  late List<String> instructions;
  late List<TipGroup> tips;
  late List<FieldInput>
      fieldInputs; // selection(range/course) + int with max value + club selection
  late List<Note?> notes;
  late Benchmark benchmarks;

  late AttributeWeightings attributeWeightings;

  late String weightingBandId;

  // for publishing to users
  late bool status;

  // for references
  late String attributeId;

  PhysicalChallenge([input, key]) {
    try {
      name = input?['name'] ?? "";
      id = input?['id'] ?? key;
      description = input?['description'] ?? "";
      purpose = input?['purpose'] ?? "";
      duration = input?['duration'] ?? "";
      difficulty = double.parse(input?['difficulty'] ?? "0");
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

      attributeWeightings = AttributeWeightings(input?['attributeWeightings']);
      fieldInputs = input?['fieldInputs'] != null
          ? (input?['fieldInputs'] as Iterable)
              .map((inputData) => FieldInput(inputData))
              .toList()
          : [];
      weightingBandId = input?['weightingBandId'];
      status = input['status'] ?? true;
      notes = input?['notes'] != null
          ? (input?['notes'] as Iterable)
              .map((noteData) => Note(noteData))
              .toList()
          : [];
      attributeId = input?['attributeId'];
      benchmarks = Benchmark(input?['benchmarks']);
    } catch (e) {
      print("PHYSICAL CHALLENGE MODEL ERROR: $e");
    }
  }

  PhysicalChallenge.init({
    required this.name,
    required this.id,
    required this.description,
    required this.purpose,
    required this.difficulty,
    required this.duration,
    required this.videoUrl,
    required this.imageUrl,
    required this.equipment,
    required this.instructions,
    required this.tips,
    required this.attributeWeightings,
    required this.fieldInputs,
    required this.weightingBandId,
    required this.benchmarks,
    required this.status,
    required this.attributeId,
    required this.notes,
  });

  getJson() {
    return {
      'name': name,
      'id': id,
      'description': description,
      'purpose': purpose,
      'difficulty': difficulty.toString(),
      'duration': duration,
      'videoUrl': videoUrl,
      'imageUrl': imageUrl,
      'equipment': equipment,
      'instructions': instructions,
      'tips': tips.map((tip) => tip.getJson()),
      'fieldInputs': fieldInputs.map((fieldInput) => fieldInput.getJson()),
      'weightingBandId': weightingBandId,
      'status': status,
      'notes': notes.map((note) => note?.getJson()),
      'attributeWeightings': attributeWeightings.getJson(),
      'attributeId': attributeId,
      'benchmarks': benchmarks.getJson(),
    };
  }
}
