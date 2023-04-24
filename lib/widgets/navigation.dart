import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:smartgolfportal/router.dart';
import 'package:smartgolfportal/services/auth_service.dart';

import '../state/user/models/user.model.dart';

class NavigationWidget extends ConsumerWidget {
  NavigationWidget(
      {Key? key,
      required this.activePage,
      this.titleOverride = "",
      required this.child,
      this.showSearchBar = true,
      this.searchFunction,
      this.actions,
      this.showBackOnTitle = false})
      : super(key: key);

  final String activePage;
  final String titleOverride;
  final bool showSearchBar;
  final Widget child;
  final List<Widget>? actions;
  final Function? searchFunction;
  final bool showBackOnTitle;

  final double _responsiveWidth = 1500;

  final TextEditingController searchController = TextEditingController();

  Widget searchBar(double width) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      margin: EdgeInsets.only(right: Get.width * 0.02),
      child: Row(
        children: [
          SizedBox(
            height: 22,
            width: width * 0.18,
            child: TextFormField(
              controller: searchController,
              decoration: const InputDecoration(
                  hintText: "Search", border: InputBorder.none),
            ),
          ),
          GestureDetector(
            child: const Icon(Icons.search),
            onTap: () => searchFunction!(searchController.text),
          ),
        ],
      ),
    );
  }

  Widget navTile(String title, IconData? iconData, double width, String link,
      {ImageIcon? icon}) {
    bool isActive = activePage == title;
    Color backgroundColor =
        isActive ? Get.theme.colorScheme.secondary : Get.theme.primaryColor;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (link == "/logout") {
            AuthService().signOut();
          } else {
            Get.offNamed(link);
          }
        },
        child: Container(
          constraints: const BoxConstraints(maxHeight: 60),
          padding: const EdgeInsets.only(left: 14),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: const Border(
              bottom: BorderSide(color: Colors.white, width: 4),
            ),
          ),
          child: Row(children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20, right: 10),
              child: iconData != null
                  ? Icon(
                      iconData,
                      color: Colors.white,
                    )
                  : icon,
            ),
            if (width > _responsiveWidth)
              FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  title,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal),
                ),
              )
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, ref) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    User currentUser = ref.watch(userStateProvider);

    Image imageBig = Image.asset(
      "assets/images/smart_stats_logo.png",
      fit: BoxFit.contain,
    );
    Image imageSmall = Image.asset("assets/images/splash_logo.png");

    return Row(
      children: [
        Column(
          children: [
            Container(
              constraints: BoxConstraints(
                  maxWidth:
                      screenWidth > _responsiveWidth ? screenWidth * 0.12 : 60,
                  maxHeight: Get.height),
              decoration: BoxDecoration(
                  color: Get.theme.primaryColor,
                  borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(50))),
              child: ListView(
                  shrinkWrap: true,
                  controller: ScrollController(),
                  children: [
                    screenWidth > _responsiveWidth
                        ? Container(color: Colors.white, child: imageBig)
                        : imageSmall,
                    Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Get.theme.primaryColor,
                        border: const Border(
                          bottom: BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        currentUser.name ?? "",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    // navTile("Dashboard", Icons.dashboard, screenWidth,
                    //     AppRoutes.dashboardScreen),
                    navTile("Users", Icons.person, screenWidth,
                        AppRoutes.userScreen),
                    navTile("Golf Challenges", Icons.golf_course, screenWidth,
                        AppRoutes.golfChallengeScreen),
                    navTile(
                        "Skills & Elements",
                        Icons.switch_access_shortcut_add,
                        screenWidth,
                        AppRoutes.skillElementScreen),
                    navTile("Physical Challenges", Icons.fitness_center,
                        screenWidth, AppRoutes.physicalScreen),
                    navTile("Attributes", Icons.grade, screenWidth,
                        AppRoutes.attributeScreen),
                    navTile("Notes", Icons.note, screenWidth,
                        AppRoutes.notesScreen),
                    navTile("Weighting Bands", Icons.percent, screenWidth,
                        AppRoutes.weightingBandsScreen),
                    navTile("Promotional Draw", null, screenWidth,
                        AppRoutes.promotionalDrawScreen,
                        icon: const ImageIcon(
                          AssetImage('assets/images/ticket_icon.png'),
                          color: Colors.white,
                        )),
                    navTile("Vouchers", Icons.monetization_on, screenWidth,
                        AppRoutes.voucherScreen),
                    navTile("Logout", Icons.logout, screenWidth, "/logout"),
                    Container(
                      height: 30,
                      margin: const EdgeInsets.only(top: 10),
                    )
                  ]),
            ),
          ],
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: Get.height * 0.08,
                    decoration: BoxDecoration(color: Get.theme.primaryColor),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (showSearchBar) searchBar(screenWidth),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight - Get.height * 0.08,
                    child: Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: 90,
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Get.theme.primaryColor,
                                        width: 4))),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: showBackOnTitle
                                        ? Row(
                                            children: [
                                              BackButton(
                                                onPressed: () {
                                                  Get.back();
                                                },
                                              ),
                                              Text(
                                                titleOverride.isNotEmpty
                                                    ? titleOverride
                                                    : activePage,
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          )
                                        : Text(
                                            titleOverride.isNotEmpty
                                                ? titleOverride
                                                : activePage,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                  ),
                                  ...?actions
                                ],
                              ),
                            ),
                          ),
                          Flexible(
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: child),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
