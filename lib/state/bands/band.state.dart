import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/db_service.dart';
import 'models/weighting_bands.model.dart';

final DBService _dbService = DBService();

class BandStateModel extends ChangeNotifier {
  List<WeightingBands> bands;
  bool initSet;
  bool isLoading;
  int dataRange;

  BandStateModel(
      {this.bands = const [],
      this.initSet = false,
      this.isLoading = false,
      this.dataRange = 0});

  initBands() async {
    if (initSet == false) {
      isLoading = true;
      notifyListeners();

      List<WeightingBands> bands = await _dbService.fetchBands();

      this.bands = bands;
      isLoading = false;
      initSet = true;
      notifyListeners();
    }
  }

  List<WeightingBands> fetchPaginatedWeightingBandsList(
      {String? action, String? searchTerm}) {
    List<WeightingBands> bands = [...this.bands];

    if (searchTerm != null && searchTerm.isNotEmpty) {
      bands = bands
          .where((band) =>
              band.name.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
    }

    if (action == "plus") {
      dataRange = dataRange + 10;
    } else if (action == "minus") {
      dataRange = dataRange - 10;
    }
    int toRange =
        (dataRange + 11 > bands.length) ? bands.length : dataRange + 11;
    if (bands.isNotEmpty) {
      if (dataRange > bands.length) {
        dataRange = 0;
      }
      return bands.getRange(dataRange, toRange).toList();
    }
    return [];
  }

  Future<List<WeightingBands>> fetchAllBands() async {
    if (bands.isEmpty) {
      List<WeightingBands> bands = await _dbService.fetchBands();
      this.bands = bands;
      initSet = true;
      notifyListeners();
    }
    return Future.value(bands);
  }

  Future<void> createNewWeightingBands(WeightingBands band) async {
    await _dbService.createNewWeightingBands(band);
    bands.add(band);
    notifyListeners();
  }

  Future<void> updateWeightingBands(
      WeightingBands oldWeightingBands, WeightingBands band) async {
    WeightingBands newWeightingBands =
        await _dbService.updateWeightingBands(band);
    int index = bands.indexOf(oldWeightingBands);
    bands[index] = band;
    notifyListeners();
  }

  void deleteWeightingBands(WeightingBands band) {
    int index = bands.indexOf(band);
    _dbService.deleteWeightingBands(band);

    bands.removeAt(index);
    notifyListeners();
  }
}

final bandStateProvider = ChangeNotifierProvider(((ref) => BandStateModel()));
