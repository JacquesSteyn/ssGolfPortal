import 'package:firebase_database/firebase_database.dart';
import 'package:smartgolfportal/state/draws/models/draw.model.dart';
import 'package:smartgolfportal/state/draws/models/voucher.model.dart';
import 'package:smartgolfportal/state/feedback/models/feedback.model.dart';
import 'package:smartgolfportal/state/golf/models/element.model.dart';
import 'package:smartgolfportal/state/golf/models/golf.model.dart';
import 'package:smartgolfportal/state/golf/models/skill.model.dart';
import 'package:smartgolfportal/state/notes/note.model.dart';
import 'package:smartgolfportal/state/physical/models/attribute.model.dart';
import 'package:smartgolfportal/state/physical/models/physical.model.dart';
import 'package:smartgolfportal/state/shared_models/benchmark.model.dart';

import '../../constants/database.paths.dart';
import '../state/bands/models/weighting_bands.model.dart';
import '../state/user/models/user.model.dart' as user_model;

final _db = FirebaseDatabase.instance;
final _dbPaths = Path();

class DBService {
  //--------------------User functions--------------------

  Future<user_model.User?> fetchUser(String userID) async {
    final dbEvent =
        await _db.ref().child('Users/$userID').once(DatabaseEventType.value);
    if (dbEvent.snapshot.exists) {
      return Future.value(user_model.User(dbEvent.snapshot.value));
    } else {
      Future.value(null);
    }
    return null;
  }

  Future<List<user_model.User>> fetchUsers(
      {int limit = 11, String? startAt, String searchTerm = ""}) async {
    DatabaseReference ref = _db.ref().child(_dbPaths.userDetails);

    DatabaseEvent dbEvent;
    if (searchTerm.isNotEmpty) {
      dbEvent = await ref.orderByChild("name").limitToFirst(limit).once();
    } else if (startAt != null) {
      dbEvent = await ref
          .orderByChild("name")
          .startAt(startAt)
          .limitToFirst(limit)
          .once();
    } else {
      dbEvent = await ref.orderByChild("name").limitToFirst(limit).once();
    }

    List<user_model.User> tempList = [];
    if (dbEvent.snapshot.exists) {
      for (var child in dbEvent.snapshot.children) {
        tempList.add(user_model.User(child.value));
      }
    }
    return Future.value(tempList);
  }

  Future<user_model.User?> searchUser() async {
    return null;
  }

  Future<String> toggleUserPlan(user_model.User user) async {
    if (user.id != null && user.id!.isNotEmpty) {
      DateTime now = DateTime.now();
      DateTime oneYear = DateTime(now.year + 1, now.month, now.day);

      DatabaseReference ref =
          _db.ref().child("${_dbPaths.userDetails}/${user.id}");
      String newPlan = user.plan == "free" ? "pro" : "free";
      await ref
          .update({"plan": newPlan, "freeTrailExpireDate": oneYear.toString()});
      return Future.value(newPlan);
    } else {
      return Future.value(user.plan ?? "free");
    }
  }

  //--------------------User functions ends-------------------

  //--------------------Golf functions starts-------------------

  Future<List<GolfChallenge>> fetchGolfChallenges() async {
    DatabaseReference ref = _db.ref().child(_dbPaths.golfChallenges);

    DatabaseEvent dbEvent = await ref.orderByChild("name").once();

    List<GolfChallenge> tempList = [];
    if (dbEvent.snapshot.exists) {
      for (var child in dbEvent.snapshot.children) {
        GolfChallenge challenge = GolfChallenge(child.value, child.key);
        tempList.add(challenge);
      }
    }
    return Future.value(tempList);
  }

  Future<Benchmark> fetchGolfOverallPhysicalBenchmarks() async {
    DatabaseReference ref = _db.ref().child(_dbPaths.golfOverallPhysical);

    DatabaseEvent dbEvent = await ref.once();

    if (dbEvent.snapshot.exists) {
      return Future.value(Benchmark(dbEvent.snapshot.value));
    }
    return Future.value(Benchmark.empty());
  }

  Future<Benchmark> updateGolfOverallPhysicalBenchmarks(
      Benchmark benchmark) async {
    await _db.ref(_dbPaths.golfOverallPhysical).update(benchmark.getJson());
    return benchmark;
  }

  Future<List<Skill>> fetchGolfSkills() async {
    DatabaseReference ref = _db.ref().child(_dbPaths.golfSkill);
    DatabaseEvent dbEvent = await ref.once();

    List<Skill> tempList = [];
    if (dbEvent.snapshot.exists) {
      for (var child in dbEvent.snapshot.children) {
        Skill skill = Skill(child.value, child.key);
        tempList.add(skill);
      }
    }
    return Future.value(tempList);
  }

  Future<bool> toggleGolfChallengeStatus(GolfChallenge challenge) async {
    if (challenge.id.isNotEmpty) {
      DatabaseReference ref =
          _db.ref().child("${_dbPaths.golfChallenges}/${challenge.id}");
      await ref.update({"status": !challenge.status});
      return !challenge.status;
    } else {
      return challenge.status;
    }
  }

  Future<List<AppFeedback>> fetchChallengeFeedback(challengeID) async {
    DatabaseReference ref = _db.ref().child(_dbPaths.feedback);
    DatabaseEvent dbEvent =
        await ref.orderByChild("challengeId").equalTo(challengeID).once();

    List<AppFeedback> tempList = [];
    if (dbEvent.snapshot.exists) {
      for (var child in dbEvent.snapshot.children) {
        AppFeedback feedback = AppFeedback(child.value, child.key);
        tempList.add(feedback);
      }
    }
    return Future.value(tempList);
  }

  Future<String> fetchChallengeFeedbackCount(challengeID) async {
    DatabaseReference ref =
        _db.ref().child("${_dbPaths.feedbackCount}/$challengeID/count");
    DatabaseEvent dbEvent = await ref.once();
    if (dbEvent.snapshot.exists) {
      return Future.value(dbEvent.snapshot.value.toString());
    }
    return Future.value("0");
  }

  Future<String> fetchChallengeResultsCount(challengeID) async {
    DatabaseReference ref =
        _db.ref().child("${_dbPaths.feedbackResultsCount}/$challengeID/count");
    DatabaseEvent dbEvent = await ref.once();
    if (dbEvent.snapshot.exists) {
      return dbEvent.snapshot.value.toString();
    }
    return "0";
  }

  Future<GolfChallenge> createNewGolfChallenge(GolfChallenge challenge) async {
    DatabaseReference ref = _db.ref(_dbPaths.golfChallenges).push();
    challenge.id = ref.key!;
    await ref.update(challenge.getJson());

    return challenge;
  }

  Future<GolfChallenge> updateGolfChallenge(GolfChallenge challenge) async {
    await _db
        .ref(_dbPaths.golfChallenges + "/" + challenge.id)
        .update(challenge.getJson());
    return challenge;
  }

  Future<Skill> createNewSkill(Skill skill) async {
    DatabaseReference ref = _db.ref(_dbPaths.golfSkill).push();
    skill.id = ref.key!;
    await ref.update(skill.getJson());
    return skill;
  }

  Future<Skill> updateSkill(Skill skill) async {
    await _db.ref(_dbPaths.golfSkill + "/" + skill.id).update(skill.getJson());
    return skill;
  }

  void deleteSkill(Skill skill) {
    if (skill.id.isNotEmpty) {
      _db.ref(_dbPaths.golfSkill + "/" + skill.id).remove();
    }
  }

  void deleteSkillElement(Skill skill, SkillElement element) {
    if (skill.id.isNotEmpty) {
      _db
          .ref(_dbPaths.golfSkill +
              "/" +
              skill.id +
              "/elements/" +
              element.id.toString())
          .remove();
    }
  }

  //--------------------Golf functions ends-------------------

  //--------------------Physical functions starts-------------------

  Future<List<PhysicalChallenge>> fetchPhysicalChallenges() async {
    DatabaseReference ref = _db.ref().child(_dbPaths.physicalChallenges);

    DatabaseEvent dbEvent = await ref.orderByChild("name").once();

    List<PhysicalChallenge> tempList = [];
    if (dbEvent.snapshot.exists) {
      for (var child in dbEvent.snapshot.children) {
        PhysicalChallenge challenge = PhysicalChallenge(child.value, child.key);
        tempList.add(challenge);
      }
    }
    return Future.value(tempList);
  }

  Future<List<Attribute>> fetchPhysicalAttributes() async {
    DatabaseReference ref = _db.ref().child(_dbPaths.physicalAttributes);
    DatabaseEvent dbEvent = await ref.once();

    List<Attribute> tempList = [];
    if (dbEvent.snapshot.exists) {
      for (var child in dbEvent.snapshot.children) {
        //Need to provide the key as attributes do not have a id field in the set
        Attribute attribute = Attribute(child.value, child.key);
        tempList.add(attribute);
      }
    }
    return Future.value(tempList);
  }

  Future<PhysicalChallenge> createNewPhysicalChallenge(
      PhysicalChallenge challenge) async {
    DatabaseReference ref = _db.ref(_dbPaths.physicalChallenges).push();
    challenge.id = ref.key!;
    await ref.update(challenge.getJson());

    return challenge;
  }

  Future<PhysicalChallenge> updatePhysicalChallenge(
      PhysicalChallenge challenge) async {
    await _db
        .ref(_dbPaths.physicalChallenges + "/" + challenge.id)
        .update(challenge.getJson());
    return challenge;
  }

  Future<bool> togglePhysicalChallengeStatus(
      PhysicalChallenge challenge) async {
    if (challenge.id.isNotEmpty) {
      DatabaseReference ref =
          _db.ref().child("${_dbPaths.physicalChallenges}/${challenge.id}");
      await ref.update({"status": !challenge.status});
      return !challenge.status;
    } else {
      return challenge.status;
    }
  }

  Future<Attribute> createNewAttribute(Attribute att) async {
    DatabaseReference ref = _db.ref(_dbPaths.physicalAttributes).push();
    att.id = ref.key!;
    await ref.update(att.getJson());
    return att;
  }

  Future<Attribute> updateAttribute(Attribute attribute) async {
    await _db
        .ref(_dbPaths.physicalAttributes + "/" + attribute.id)
        .update(attribute.getJson());
    return attribute;
  }

  void deleteAttribute(Attribute att) {
    if (att.id.isNotEmpty) {
      _db.ref(_dbPaths.physicalAttributes + "/" + att.id).remove();
    }
  }

  //--------------------Physical functions ends-------------------

  //--------------------Notes functions starts-------------------
  Future<List<Note>> fetchNotes() async {
    DatabaseReference ref = _db.ref().child(_dbPaths.notes);
    DatabaseEvent dbEvent = await ref.orderByChild("title").once();

    List<Note> tempList = [];
    if (dbEvent.snapshot.exists) {
      for (var child in dbEvent.snapshot.children) {
        Note note = Note(child.value, child.key);
        tempList.add(note);
      }
    }
    return Future.value(tempList);
  }

  Future<Note> createNewNote(Note note) async {
    DatabaseReference ref = _db.ref(_dbPaths.notes).push();
    note.id = ref.key!;
    await ref.update(note.getJson());
    return note;
  }

  Future<Note> updateNote(Note note) async {
    await _db.ref(_dbPaths.notes + "/" + note.id).update(note.getJson());
    return note;
  }

  void deleteNote(Note note) {
    if (note.id.isNotEmpty) {
      _db.ref(_dbPaths.notes + "/" + note.id).remove();
    }
  }

  void deleteNoteOption(Note note, String optionID) {
    if (note.id.isNotEmpty && optionID.isNotEmpty) {
      //print(_dbPaths.notes + "/" + note.id + "/options/" + optionID);
      _db.ref(_dbPaths.notes + "/" + note.id + "/options/" + optionID).remove();
    }
  }

  //--------------------Notes functions ends-------------------

  //--------------------Bands functions starts-------------------

  Future<List<WeightingBands>> fetchBands() async {
    DatabaseReference ref = _db.ref().child(_dbPaths.bands);
    DatabaseEvent dbEvent = await ref.once();

    List<WeightingBands> tempList = [];
    if (dbEvent.snapshot.exists) {
      for (var child in dbEvent.snapshot.children) {
        WeightingBands bands = WeightingBands(child.value, child.key);
        tempList.add(bands);
      }
    }
    return Future.value(tempList);
  }

  Future<WeightingBands> createNewWeightingBands(WeightingBands band) async {
    DatabaseReference ref = _db.ref(_dbPaths.bands).push();
    band.id = ref.key!;
    await ref.update(band.getJson());
    return band;
  }

  Future<WeightingBands> updateWeightingBands(WeightingBands band) async {
    await _db.ref(_dbPaths.bands + "/" + band.id).update(band.getJson());

    return band;
  }

  void deleteWeightingBands(WeightingBands band) {
    if (band.id.isNotEmpty) {
      _db.ref(_dbPaths.bands + "/" + band.id).remove();
    }
  }

  //--------------------Bands functions ends-------------------

  //--------------------Promotional draw functions starts-------------------

  Future<List<PromotionalDraw>> fetchPromotionalDraws() async {
    DatabaseReference ref = _db.ref().child(_dbPaths.promotionalDraws);

    DatabaseEvent dbEvent = await ref.orderByChild("drawDate").once();

    List<PromotionalDraw> tempList = [];
    if (dbEvent.snapshot.exists) {
      for (var child in dbEvent.snapshot.children) {
        PromotionalDraw draw = PromotionalDraw(child.value, child.key);
        tempList.add(draw);
      }
    }
    return Future.value(tempList);
  }

  Future<PromotionalDraw> createNewPromotionalDraw(PromotionalDraw draw) async {
    DatabaseReference ref = _db.ref(_dbPaths.promotionalDraws).push();
    draw.id = ref.key!;
    await ref.update(draw.getJson());

    return draw;
  }

  void deletePromotionalDraw(PromotionalDraw draw) async {
    if (draw.id.isNotEmpty) {
      await _db.ref(_dbPaths.promotionalDraws + "/" + draw.id).remove();
    }
  }

  Future<PromotionalDraw> updatePromotionalDraw(PromotionalDraw draw) async {
    await _db
        .ref(_dbPaths.promotionalDraws + "/" + draw.id)
        .update(draw.getJson());
    return draw;
  }

  //--------------------Promotional draw functions ends-------------------

  //--------------------Vouchers functions starts-------------------

  Future<List<Voucher>> fetchVouchers() async {
    DatabaseReference ref = _db.ref().child(_dbPaths.vouchers);

    DatabaseEvent dbEvent = await ref.orderByChild("voucherExpireDate").once();

    List<Voucher> tempList = [];
    if (dbEvent.snapshot.exists) {
      for (var child in dbEvent.snapshot.children) {
        Voucher voucher = Voucher(child.value, child.key);
        tempList.add(voucher);
      }
    }
    return Future.value(tempList);
  }

  Future<Voucher> createNewVoucher(Voucher voucher) async {
    DatabaseReference ref = _db.ref(_dbPaths.vouchers).push();
    voucher.id = ref.key!;
    await ref.update(voucher.getJson());

    return voucher;
  }

  void deleteVoucher(Voucher voucher) async {
    if (voucher.id.isNotEmpty) {
      await _db.ref(_dbPaths.vouchers + "/" + voucher.id).remove();
    }
  }

  Future<Voucher> updateVoucher(Voucher voucher) async {
    await _db
        .ref(_dbPaths.vouchers + "/" + voucher.id)
        .update(voucher.getJson());
    return voucher;
  }

  //--------------------Vouchers functions ends-------------------
}
