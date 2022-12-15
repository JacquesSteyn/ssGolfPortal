import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartgolfportal/services/db_service.dart';

import '../feedback/models/feedback.model.dart';
import 'models/attribute.model.dart';
import 'models/physical.model.dart';

final DBService _dbService = DBService();

class PhysicalStateModel extends ChangeNotifier {
  List<Attribute> physicalAttributes;
  List<PhysicalChallenge> physicalChallenges;
  bool initSet;
  bool isLoading;
  int dataRange;
  PhysicalChallenge? activeChallenge;
  List<AppFeedback?> currentFeedback;

  PhysicalStateModel(
      {this.physicalAttributes = const [],
      this.physicalChallenges = const [],
      this.currentFeedback = const [],
      this.initSet = false,
      this.isLoading = false,
      this.dataRange = 0});

  initPhysicalChallenges() async {
    if (initSet == false) {
      isLoading = true;
      notifyListeners();

      List<PhysicalChallenge> challenges =
          await _dbService.fetchPhysicalChallenges();
      List<Attribute> attributes = await _dbService.fetchPhysicalAttributes();

      physicalAttributes = attributes;
      physicalChallenges = challenges;
      isLoading = false;
      initSet = true;
      notifyListeners();
    }
  }

  Future<void> createNewChallenge(PhysicalChallenge challenge) async {
    isLoading = true;
    notifyListeners();
    try {
      PhysicalChallenge newChallenge =
          await _dbService.createNewPhysicalChallenge(challenge);
      List<PhysicalChallenge> newList = [...physicalChallenges];
      newList.add(newChallenge);
      physicalChallenges = newList;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePhysicalChallenge(
      PhysicalChallenge? oldChallenge, PhysicalChallenge challenge) async {
    if (oldChallenge != null) {
      PhysicalChallenge newChallenge =
          await _dbService.updatePhysicalChallenge(challenge);
      int index = physicalChallenges.indexOf(oldChallenge);
      physicalChallenges[index] = newChallenge;
      notifyListeners();
    }
  }

  List<PhysicalChallenge> fetchPaginatedChallengeList(
      {String? action, String? filter, String? searchTerm}) {
    List<PhysicalChallenge> challenges = [...physicalChallenges];
    if (searchTerm != null && searchTerm.isNotEmpty) {
      challenges = challenges
          .where((challenge) =>
              challenge.name.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
    }

    if (filter != null && filter.isNotEmpty && filter != "all") {
      challenges = challenges.where((challenge) {
        return challenge.attributeId == filter;
      }).toList();
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

  List<Attribute> fetchPaginatedAttributeList({String? action}) {
    if (action == "plus") {
      dataRange = dataRange + 10;
    } else if (action == "minus") {
      dataRange = dataRange - 10;
    }
    int toRange = (dataRange + 11 > physicalAttributes.length)
        ? physicalAttributes.length
        : dataRange + 11;
    if (physicalAttributes.isNotEmpty) {
      return physicalAttributes.getRange(dataRange, toRange).toList();
    }
    return [];
  }

  Attribute? fetchChallengeAttribute(String attributeID) {
    int attributeIndex =
        physicalAttributes.indexWhere((el) => el.id == attributeID);

    if (attributeIndex != -1) {
      return physicalAttributes[attributeIndex];
    }
    return null;
  }

  Future<List<Attribute>> fetchAllAttributes() async {
    if (physicalAttributes.isEmpty) {
      List<Attribute> attributes = await _dbService.fetchPhysicalAttributes();
      return Future.value(attributes);
    } else {
      return Future.value(physicalAttributes);
    }
  }

  void togglePhysicalChallenge(PhysicalChallenge challenge) async {
    await _dbService.togglePhysicalChallengeStatus(challenge);
    int index = physicalChallenges.indexOf(challenge);
    challenge.status = !challenge.status;
    physicalChallenges[index] = challenge;
    notifyListeners();
  }

  Future<void> createNewAttribute(Attribute attribute) async {
    await _dbService.createNewAttribute(attribute);
    physicalAttributes.add(attribute);
    notifyListeners();
  }

  Future<void> updateAttribute(
      Attribute oldAttribute, Attribute attribute) async {
    Attribute newAttribute = await _dbService.updateAttribute(attribute);
    int index = physicalAttributes.indexOf(oldAttribute);
    physicalAttributes[index] = newAttribute;
    notifyListeners();
  }

  void deleteAttribute(Attribute att) {
    _dbService.deleteAttribute(att);
    int index = physicalAttributes.indexOf(att);
    physicalAttributes.removeAt(index);
    notifyListeners();
  }

  Future<void> setActiveChallenge(PhysicalChallenge? challenge) {
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

final physicalStateProvider =
    ChangeNotifierProvider(((ref) => PhysicalStateModel()));
