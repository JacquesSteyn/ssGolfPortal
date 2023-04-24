import 'package:flutter/material.dart';
import 'package:smartgolfportal/services/db_service.dart';
import 'package:smartgolfportal/state/results/golf_challenge_result.model.dart';
import 'package:smartgolfportal/state/user/models/user.model.dart';

import '../state/results/challenge_input_result.model.dart';

class ChallengeResultCard extends StatelessWidget {
  final GolfChallengeResult data;
  const ChallengeResultCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(child: userName()),
            const Divider(
              height: 10,
              color: Colors.grey,
            ),
            ...inputResult()
          ],
        ),
      ),
    );
  }

  List inputResult() {
    List columnItems = [];

    if (data.dateTimeCreated != null) {
      columnItems.add(Row(
        children: [
          const Text("Date Captured: "),
          Text("${data.dateTimeCreated}"),
        ],
      ));
    }

    if (data.inputResults != null) {
      data.inputResults?.forEach((element) {
        List rowItems = [];
        if (element is ChallengeInputSelectResult) {
          ChallengeInputSelectResult result = element;
          rowItems.add(Text("${result.name}: "));
          rowItems.add(Text(result.selectedOption ?? ""));
        } else if (element is ChallengeInputSelectScoreResult) {
          ChallengeInputSelectScoreResult result = element;
          rowItems.add(Text("${result.name}: "));
          if (result.selectedOption != null) {
            rowItems.add(Text("${result.selectedOption?.option} - "));
            rowItems.add(Text(result.selectedOption?.score.toString() ?? ""));
          }
        } else if (element is ChallengeInputScoreResult) {
          ChallengeInputScoreResult result = element;
          rowItems.add(Text("${result.name}: "));
          rowItems.add(Text(result.selectedScore.toString()));
        }
        columnItems.add(Row(
          children: [...rowItems],
        ));
      });
    }
    return columnItems;
  }

  FutureBuilder? userName() {
    if (data.index != null) {
      List<String> strings = data.index!.split('_');
      if (strings.isNotEmpty) {
        String userID = strings[0];
        return FutureBuilder<User?>(
          future: DBService().fetchUser(userID),
          builder: (context, snapshot) {
            Widget child;
            if (snapshot.hasData) {
              User? user = snapshot.data;
              if (user != null) {
                child = Text(
                  'User: ${snapshot.data!.name} (${snapshot.data!.email})',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                );
              } else {
                child = const Text(
                  'User: Unknown',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                );
              }
            } else if (snapshot.hasError) {
              child = const Text(
                'User: Unknown',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              );
            } else {
              child = const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              );
            }
            return child;
          },
        );
      }
    }
    return null;
  }
}
