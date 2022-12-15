import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartgolfportal/services/db_service.dart';
import 'package:smartgolfportal/widgets/data_table.dart';
import 'package:smartgolfportal/widgets/navigation.dart';

import '../state/user/models/user.model.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  int _pageIndex = 0;
  String? _lastUser;
  String _searchTerm = "";

  void setPrevious(String firstVal) {
    setState(() {
      if (_pageIndex > 0) {
        _pageIndex = 0;
      }
      _lastUser = firstVal;
    });
  }

  void setNext(String lastVal) {
    setState(() {
      _pageIndex++;
      _lastUser = lastVal;
    });
  }

  Widget nameCell(User user) {
    if (user.type == "Admin" || user.type == "admin") {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(user.name ?? "Unknown"),
          const Icon(Icons.admin_panel_settings)
        ],
      );
    }
    return Text(user.name ?? "Unknown");
  }

  Widget userPlanSwitch(User user) {
    return Row(
      children: [
        const Text("Free"),
        Switch(
            activeColor: Colors.black,
            value: (user.plan ?? "free") == "pro",
            onChanged: (value) async {
              String plan = await DBService().toggleUserPlan(user);
              if (plan != user.plan) {
                setState(() {});
              }
            }),
        const Text("Pro")
      ],
    );
  }

  void setSearchTerm(String? term) {
    setState(() {
      _searchTerm = term ?? "";
      _pageIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NavigationWidget(
        activePage: "Users",
        showSearchBar: false,
        searchFunction: setSearchTerm,
        child: SingleChildScrollView(
          child: FutureBuilder<List<User>>(
              future: DBService()
                  .fetchUsers(startAt: _lastUser, searchTerm: _searchTerm),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return CustomDataTable(
                    pageIndex: _pageIndex,
                    onPrevious: (firstVal) => setPrevious(firstVal),
                    onNext: (lastVal) => setNext(lastVal),
                    dataReady: snapshot.hasData,
                    dataColumns: const [
                      'Full Name',
                      'Email',
                      'Date Of Birth',
                      'Gender',
                      'Plan'
                    ],
                    lastVal: snapshot.data?.last.name ?? "",
                    dataRows: snapshot.data!.map((user) {
                      return DataRow(cells: [
                        DataCell(nameCell(user)),
                        DataCell(
                          GestureDetector(
                            onTap: () async {
                              await Clipboard.setData(
                                  ClipboardData(text: user.id));
                            },
                            child: Text(user.email ?? "Unknown"),
                          ),
                        ),
                        DataCell(Text(user.dateOfBirth ?? "Unknown")),
                        DataCell(Text(user.gender ?? "Unknown")),
                        DataCell(userPlanSwitch(user)),
                      ]);
                    }).toList(),
                  );
                } else {
                  return Container();
                }
              }),
        ),
      ),
    );
  }
}
