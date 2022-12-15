import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartgolfportal/services/db_service.dart';
import 'package:smartgolfportal/state/feedback/models/feedback.model.dart';
import 'package:smartgolfportal/state/golf/models/element.model.dart';
import 'package:smartgolfportal/state/golf/models/golf.model.dart';
import 'package:smartgolfportal/state/physical/models/attribute.model.dart';
import 'package:smartgolfportal/state/shared_models/benchmark.model.dart';

import 'models/skill.model.dart';

final DBService _dbService = DBService();

class GolfStateModel extends ChangeNotifier {
  List<Skill> golfSkills;
  List<GolfChallenge> golfChallenges;
  Benchmark? overallPhysicalBenchmark;
  List<Attribute> golfAttributes;
  bool initSet;
  bool isLoading;
  int dataRange;
  GolfChallenge? activeChallenge;
  List<AppFeedback?> currentFeedback;

  GolfStateModel(
      {this.golfSkills = const [],
      this.golfAttributes = const [],
      this.golfChallenges = const [],
      this.currentFeedback = const [],
      this.initSet = false,
      this.isLoading = false,
      this.dataRange = 0});

  initGolfChallenges() async {
    if (initSet == false) {
      isLoading = true;
      notifyListeners();

      List<GolfChallenge> challenges = await _dbService.fetchGolfChallenges();
      List<Skill> skills = await _dbService.fetchGolfSkills();
      List<Attribute> attributes = await _dbService.fetchPhysicalAttributes();

      overallPhysicalBenchmark =
          await _dbService.fetchGolfOverallPhysicalBenchmarks();

      golfSkills = skills;
      golfAttributes = attributes;
      golfChallenges = challenges;
      isLoading = false;
      initSet = true;
      notifyListeners();
    }
  }

  Future<List<Skill>> fetchAllSkills() async {
    if (golfSkills.isEmpty) {
      List<Skill> skills = await _dbService.fetchGolfSkills();
      return Future.value(skills);
    } else {
      return Future.value(golfSkills);
    }
  }

  List<GolfChallenge> fetchPaginatedChallengeList(
      {String? action, String? filter, String? searchTerm}) {
    List<GolfChallenge> challenges = [...golfChallenges];

    if (searchTerm != null && searchTerm.isNotEmpty) {
      challenges = challenges
          .where((challenge) =>
              challenge.name.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
    }

    if (filter != null && filter.isNotEmpty && filter != "all") {
      try {
        challenges = challenges.where((challenge) {
          //remove index value from the id. Matching old db

          var skillID = challenge.skillIdElementId
              .substring(0, challenge.skillIdElementId.length - 1);
          return skillID == filter;
        }).toList();
      } catch (e) {
        return challenges;
      }
    }

    if (action == "plus") {
      dataRange = dataRange + 10;
    } else if (action == "minus") {
      dataRange = dataRange - 10;
    }
    int toRange = (dataRange + 11 > challenges.length)
        ? challenges.length
        : dataRange + 11;
    if (challenges.isNotEmpty) {
      if (dataRange > challenges.length) {
        dataRange = 0;
      }
      return challenges.getRange(dataRange, toRange).toList();
    }
    return [];
  }

  Future<void> createNewChallenge(GolfChallenge challenge) async {
    isLoading = true;
    notifyListeners();
    try {
      GolfChallenge newChallenge =
          await _dbService.createNewGolfChallenge(challenge);
      List<GolfChallenge> newList = [...golfChallenges];
      newList.add(newChallenge);
      golfChallenges = newList;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateGolfChallenge(
      GolfChallenge? oldChallenge, GolfChallenge challenge) async {
    if (oldChallenge != null) {
      GolfChallenge newChallenge =
          await _dbService.updateGolfChallenge(challenge);
      int index = golfChallenges.indexOf(oldChallenge);
      golfChallenges[index] = newChallenge;
      notifyListeners();
    }
  }

  Future<void> updateGolfOverallPhysicalBenchmarks(Benchmark benchmark) async {
    Benchmark newBenchmarks =
        await _dbService.updateGolfOverallPhysicalBenchmarks(benchmark);
    overallPhysicalBenchmark = newBenchmarks;
    notifyListeners();
  }

  Skill? fetchChallengeSkill(String skillID) {
    if (skillID.isNotEmpty) {
      //remove index value from the id. Matching old db
      skillID = skillID.substring(0, skillID.length - 1);

      int skillIndex = golfSkills.indexWhere((el) => el.id == skillID);
      if (skillIndex != -1) {
        return golfSkills[skillIndex];
      }
    }
    return null;
  }

  void toggleGolfChallenge(GolfChallenge challenge) async {
    await _dbService.toggleGolfChallengeStatus(challenge);
    int index = golfChallenges.indexOf(challenge);
    challenge.status = !challenge.status;
    golfChallenges[index] = challenge;
    notifyListeners();
  }

  Future<void> createNewSkill(Skill skill) async {
    await _dbService.createNewSkill(skill);
    golfSkills.add(skill);
    notifyListeners();
  }

  Future<void> updateSkill(Skill oldSkill, Skill skill) async {
    Skill newSkill = await _dbService.updateSkill(skill);
    int index = golfSkills.indexOf(oldSkill);
    golfSkills[index] = newSkill;
    notifyListeners();
  }

  void deleteSkill(Skill skill) {
    _dbService.deleteSkill(skill);
    int index = golfSkills.indexOf(skill);
    golfSkills.removeAt(index);
    notifyListeners();
  }

  void deleteSkillElement(Skill skill, SkillElement element) {
    _dbService.deleteSkillElement(skill, element);
    int index = golfSkills.indexOf(skill);
    int elementIndex = golfSkills[index].elements.indexOf(element);
    golfSkills[index].elements.removeAt(elementIndex);
    notifyListeners();
  }

  Future<void> setActiveChallenge(GolfChallenge? challenge) {
    activeChallenge = challenge;
    notifyListeners();
    return Future.value();
  }

  Future<void> setActiveFeedback(String challengeID) async {
    List<AppFeedback> fetchedFeedback =
        await _dbService.fetchChallengeFeedback(challengeID);
    currentFeedback = fetchedFeedback;
    notifyListeners();
    return Future.value();
  }
}

final golfStateProvider = ChangeNotifierProvider(((ref) => GolfStateModel()));
