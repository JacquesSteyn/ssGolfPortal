import 'package:flutter/material.dart';
import 'package:smartgolfportal/screens/attributes_screen.dart';
import 'package:smartgolfportal/screens/challenge_result_screen.dart';
import 'package:smartgolfportal/screens/feedback_screen.dart';
import 'package:smartgolfportal/screens/golf_challenge_edit_screen.dart';
import 'package:smartgolfportal/screens/golf_challenge_screen.dart';
import 'package:smartgolfportal/screens/notes_screen.dart';
import 'package:smartgolfportal/screens/physical_challenge_edit_screen.dart';
import 'package:smartgolfportal/screens/physical_challenge_screen.dart';
import 'package:smartgolfportal/screens/promotional_draw_edit_screen.dart';
import 'package:smartgolfportal/screens/promotional_draw_screen.dart';
import 'package:smartgolfportal/screens/promotional_draw_view_screen.dart';
import 'package:smartgolfportal/screens/skill_screen.dart';
import 'package:smartgolfportal/screens/user_screen.dart';
import 'package:smartgolfportal/screens/voucher_edit_screen.dart';
import 'package:smartgolfportal/screens/voucher_screen.dart';
import 'package:smartgolfportal/screens/voucher_view_screen.dart';
import 'package:smartgolfportal/screens/weight_band_screen.dart';

import 'screens/login_screen.dart';

class AppRoutes {
  static const loginScreen = '/login';
  //static const dashboardScreen = '/dashboard';
  static const userScreen = "/users";
  static const challengeResultScreen = "/challengeResultScreen";
  static const golfChallengeScreen = "/golfChallenge";
  static const golfEditScreen = "/golfEdit";
  static const skillElementScreen = "/skillElement";
  static const physicalScreen = "/physicalChallenge";
  static const physicalEditScreen = "/physicalEdit";
  static const attributeScreen = "/attributes";
  static const notesScreen = "/notes";
  static const weightingBandsScreen = "/weightingBands";
  static const feedbackScreen = "/feedback";
  static const promotionalDrawScreen = "/promo-draw";
  static const promotionalDrawEditScreen = "/promo-drawEdit";
  static const promotionalDrawViewScreen = "/promo-drawView";
  static const voucherScreen = "/voucher-screen";
  static const voucherEditScreen = "/voucher-screenEdit";
  static const voucherViewScreen = "/voucher-screenView";

  static Map<String, Widget Function(BuildContext)> routes = {
    loginScreen: (_) => const LoginScreen(),
    //dashboardScreen: (_) => const DashboardScreen(),
    userScreen: (_) => const UserScreen(),
    challengeResultScreen: (_) => const ChallengeResultScreen(),
    golfChallengeScreen: (_) => const GolfChallengeScreen(),
    golfEditScreen: (_) => const GolfEditScreen(),
    skillElementScreen: (_) => const SkillElementScreen(),
    physicalScreen: (_) => const PhysicalChallengeScreen(),
    physicalEditScreen: (_) => const PhysicalEditScreen(),
    attributeScreen: (_) => const AttributesScreen(),
    notesScreen: (_) => const NotesScreen(),
    weightingBandsScreen: (_) => const WeightBandScreen(),
    feedbackScreen: (_) => const FeedbackScreen(),
    promotionalDrawScreen: (_) => const PromotionalDrawScreen(),
    promotionalDrawEditScreen: (_) => const PromotionalDrawEditScreen(),
    promotionalDrawViewScreen: (_) => PromotionalDrawViewScreen(),
    voucherScreen: (_) => const VoucherScreen(),
    voucherEditScreen: (_) => const VoucherEditScreen(),
    voucherViewScreen: (_) => VoucherViewScreen()
  };
}
