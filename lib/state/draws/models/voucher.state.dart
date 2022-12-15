import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartgolfportal/state/draws/models/voucher.model.dart';
import 'package:smartgolfportal/state/user/models/user.model.dart';

import '../../../services/db_service.dart';

final DBService _dbService = DBService();

class VoucherStateModel extends ChangeNotifier {
  List<Voucher> voucherList;
  bool initSet;
  bool isLoading;
  int dataRange;
  Voucher? activeVoucher;

  VoucherStateModel(
      {this.voucherList = const [],
      this.initSet = false,
      this.isLoading = false,
      this.dataRange = 0});

  initVoucherList() async {
    if (initSet == false) {
      isLoading = true;
      notifyListeners();

      List<Voucher> vouchers = await _dbService.fetchVouchers();

      voucherList = vouchers;

      isLoading = false;
      initSet = true;
      notifyListeners();
    }
  }

  List<Voucher> fetchPaginatedVoucherList({
    String? action,
    String? filter,
    String? searchTerm,
  }) {
    List<Voucher> vouchers = [...voucherList];

    if (searchTerm != null && searchTerm.isNotEmpty) {
      vouchers = vouchers
          .where((voucher) =>
              voucher.voucherName
                  .toLowerCase()
                  .contains(searchTerm.toLowerCase()) ||
              voucher.voucherNumber.contains(searchTerm))
          .toList();
    }

    if (filter != null && filter.isNotEmpty && filter != "all") {
      try {
        vouchers = vouchers.where((voucher) {
          return voucher.voucherStatus == filter;
        }).toList();
      } catch (e) {
        return vouchers;
      }
    }

    if (action == "plus") {
      dataRange = dataRange + 10;
    } else if (action == "minus") {
      dataRange = dataRange - 10;
    }
    int toRange =
        (dataRange + 11 > vouchers.length) ? vouchers.length : dataRange + 11;
    if (vouchers.isNotEmpty) {
      if (dataRange > vouchers.length) {
        dataRange = 0;
      }
      return vouchers.getRange(dataRange, toRange).toList();
    }
    return [];
  }

  Future<void> setActiveVoucher(Voucher? voucher) {
    activeVoucher = voucher;
    notifyListeners();
    return Future.value();
  }

  Future<Voucher?> createNewVoucher(Voucher voucher) async {
    isLoading = true;
    notifyListeners();
    try {
      Voucher newVoucher = await _dbService.createNewVoucher(voucher);
      List<Voucher> newList = [...voucherList];
      newList.add(newVoucher);
      voucherList = newList;
      isLoading = false;

      notifyListeners();
      return newVoucher;
    } catch (e) {
      print(e);
      isLoading = false;

      notifyListeners();
      return null;
    }
  }

  void deleteVoucher(Voucher voucher) {
    _dbService.deleteVoucher(voucher);
    int index = voucherList.indexOf(voucher);
    voucherList.removeAt(index);
    notifyListeners();
  }

  Future<void> updateVoucher(Voucher? oldVoucher, Voucher voucher) async {
    if (oldVoucher != null) {
      Voucher newVoucher = await _dbService.updateVoucher(voucher);
      int index = voucherList.indexOf(oldVoucher);
      voucherList[index] = newVoucher;
      notifyListeners();
    }
  }

  Future<Map<String, User>> fetchVoucherUsers(Voucher voucher) async {
    Map<String, User> tempList = {};
    if (voucher.redeemedVouchers.isNotEmpty) {
      for (RedeemedVoucher obj in voucher.redeemedVouchers) {
        if (!tempList.containsKey(obj.userID)) {
          User? user = await _dbService.fetchUser(obj.userID);
          if (user != null) {
            tempList.addAll({obj.userID: user});
          }
        }
      }
    }

    return Future.value(tempList);
  }
}

final voucherStateProvider =
    ChangeNotifierProvider(((ref) => VoucherStateModel()));
