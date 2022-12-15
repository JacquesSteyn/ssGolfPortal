import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartgolfportal/state/draws/models/draw.model.dart';
import 'package:smartgolfportal/state/draws/models/draw_ticket.modal.dart';
import 'package:smartgolfportal/state/user/models/user.model.dart';

import '../../services/db_service.dart';

final DBService _dbService = DBService();

class DrawStateModel extends ChangeNotifier {
  List<PromotionalDraw> promotionalDraws;
  bool initSet;
  bool isLoading;
  int dataRange;
  PromotionalDraw? activeDraw;

  DrawStateModel(
      {this.promotionalDraws = const [],
      this.initSet = false,
      this.isLoading = false,
      this.dataRange = 0});

  initPromotionalDraws() async {
    if (initSet == false) {
      isLoading = true;
      notifyListeners();

      List<PromotionalDraw> draws = await _dbService.fetchPromotionalDraws();

      promotionalDraws = draws;

      isLoading = false;
      initSet = true;
      notifyListeners();
    }
  }

  List<PromotionalDraw> fetchPaginatedDrawList(
      {String? action,
      String? filter,
      String? searchTerm,
      bool filterClosed = false}) {
    List<PromotionalDraw> draws = [...promotionalDraws];

    if (searchTerm != null && searchTerm.isNotEmpty) {
      draws = draws
          .where((draw) =>
              draw.name.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
    }

    if (filter != null && filter.isNotEmpty && filter != "all") {
      try {
        draws = draws.where((draw) {
          if (filterClosed) {
            return draw.drawType == filter && draw.drawStatus == "closed";
          } else {
            return draw.drawType == filter && draw.drawStatus == "open";
          }
        }).toList();
      } catch (e) {
        return draws;
      }
    } else {
      try {
        draws = draws.where((draw) {
          if (filterClosed) {
            return draw.drawStatus == "closed";
          } else {
            return draw.drawStatus == "open";
          }
        }).toList();
      } catch (e) {
        return draws;
      }
    }

    if (action == "plus") {
      dataRange = dataRange + 10;
    } else if (action == "minus") {
      dataRange = dataRange - 10;
    }
    int toRange =
        (dataRange + 11 > draws.length) ? draws.length : dataRange + 11;
    if (draws.isNotEmpty) {
      if (dataRange > draws.length) {
        dataRange = 0;
      }
      return draws.getRange(dataRange, toRange).toList();
    }
    return [];
  }

  Future<void> setActiveDraw(PromotionalDraw? draw) {
    activeDraw = draw;
    notifyListeners();
    return Future.value();
  }

  Future<void> createNewPromotional(PromotionalDraw draw) async {
    isLoading = true;
    notifyListeners();
    try {
      PromotionalDraw newDraw = await _dbService.createNewPromotionalDraw(draw);
      List<PromotionalDraw> newList = [...promotionalDraws];
      newList.add(newDraw);
      promotionalDraws = newList;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
    }
  }

  void deletePromotionalDraw(PromotionalDraw draw) {
    _dbService.deletePromotionalDraw(draw);
    int index = promotionalDraws.indexOf(draw);
    promotionalDraws.removeAt(index);
    notifyListeners();
  }

  Future<void> updatePromotionalDraw(
      PromotionalDraw? oldDraw, PromotionalDraw draw) async {
    if (oldDraw != null) {
      PromotionalDraw newDraw = await _dbService.updatePromotionalDraw(draw);
      int index = promotionalDraws.indexOf(oldDraw);
      promotionalDraws[index] = newDraw;
      notifyListeners();
    }
  }

  Future<Map<String, User>> fetchTicketUsers(PromotionalDraw draw) async {
    Map<String, User> tempList = {};
    if (draw.tickets.isNotEmpty) {
      for (DrawTicket ticket in draw.tickets) {
        if (!tempList.containsKey(ticket.userID)) {
          User? user = await _dbService.fetchUser(ticket.userID);
          if (user != null) {
            tempList.addAll({ticket.userID: user});
          }
        }
      }
    }

    return Future.value(tempList);
  }
}

final drawStateProvider = ChangeNotifierProvider(((ref) => DrawStateModel()));
