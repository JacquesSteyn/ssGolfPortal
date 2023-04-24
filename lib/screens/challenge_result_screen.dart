import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:smartgolfportal/services/db_service.dart';

import '../state/results/golf_challenge_result.model.dart';
import '../widgets/challenge_result_card.dart';
import '../widgets/navigation.dart';

class ChallengeResultScreen extends ConsumerStatefulWidget {
  const ChallengeResultScreen({Key? key}) : super(key: key);

  @override
  _ChallengeResultScreenState createState() => _ChallengeResultScreenState();
}

class _ChallengeResultScreenState extends ConsumerState<ChallengeResultScreen> {
  String? challengeID;
  String? challengeName;
  String? challengeType;

  @override
  void initState() {
    super.initState();
    final Map params = Get.arguments ?? {};
    if (params.containsKey('challengeId') &&
        params.containsKey('challengeType') &&
        params.containsKey('challengeName')) {
      challengeID = params['challengeId'];
      challengeName = params['challengeName'];
      challengeType = params['challengeType'];
    } else {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NavigationWidget(
          activePage: title(),
          showSearchBar: false,
          showBackOnTitle: true,
          child: challengeResultsStream()),
    );
  }

  String title() {
    if (challengeType != null) {
      if (challengeType == 'physical') {
        return 'Physical Results for $challengeName';
      } else {
        return 'Golf Results for $challengeName';
      }
    }
    return '';
  }

  Widget challengeResultsStream() {
    return StreamBuilder(
      stream: DBService().streamedChallengeResults(challengeID!),
      builder: (context, snap) {
        if (snap.hasData && !snap.hasError && snap.data != null) {
          Map? rawChallengeData = (snap.data as DatabaseEvent).snapshot.value
              as Map<Object?, dynamic>;
          List<ChallengeResultCard> challengeCards = [];

          rawChallengeData.forEach((key, value) {
            GolfChallengeResult result = GolfChallengeResult(value, key);
            challengeCards.add(ChallengeResultCard(data: result));
          });

          if (challengeCards.isEmpty) {
            return const Center(
              child: Text(
                'No completed challenges yet.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            itemCount: challengeCards.length,
            itemBuilder: (context, index) {
              return challengeCards[index];
            },
          );
        }

        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // No Results
        WidgetsBinding.instance.addPostFrameCallback((_) {
          print('No results');
        });

        return const Center(
          child: Text(
            'None',
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }
}
