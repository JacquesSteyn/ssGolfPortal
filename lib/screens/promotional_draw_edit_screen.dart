import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smartgolfportal/edit_widgets/edit_draw_media_inputs.dart';
import 'package:smartgolfportal/edit_widgets/edit_draw_rule_inputs.dart';
import 'package:smartgolfportal/services/db_service.dart';

import 'package:smartgolfportal/state/draws/draw.state.dart';
import 'package:smartgolfportal/state/draws/models/draw.model.dart';
import 'package:smartgolfportal/state/draws/models/draw_ticket.modal.dart';
import 'package:smartgolfportal/state/user/models/user.model.dart';

import 'package:smartgolfportal/widgets/custom_text_field.dart';

import '../widgets/data_table.dart';
import '../widgets/navigation.dart';

class PromotionalDrawEditScreen extends ConsumerStatefulWidget {
  const PromotionalDrawEditScreen({Key? key}) : super(key: key);

  @override
  _PromotionalDrawEditScreenState createState() =>
      _PromotionalDrawEditScreenState();
}

class _PromotionalDrawEditScreenState
    extends ConsumerState<PromotionalDrawEditScreen> {
  int _stepIndex = 0;
  bool isLoading = true;
  String errorMessage = "";
  bool newDraw = true;
  PromotionalDraw? oldDraw;

  bool confirmedWinner = false;

  DateFormat customDateFormat = DateFormat("d/M/y");

  final GlobalKey<FormState> _PromotionalDrawFormKey = GlobalKey<FormState>();

  //inputs
  late String id = "";
  late String name = "";
  late String drawType = ""; //free - pro (def: pro)
  DateTime? drawDate;
  late int ticketsSold = 0;
  late int maxPerUserEntries = 1;
  late int totalTicketsIssued = 50;
  late double ticketPrice = 0;
  late double retailPrice = 0;
  late String aboutOffer = "";
  late List<String> rules = [];
  late String sponsorName = "";
  late String sponsorWhoWeAre = "";
  late String sponsorMission = "";
  late String sponsorOrigin = "";
  late String sponsorFindUs = "";
  late String sponsorLink = "";
  late String image1Url = "";
  late String image2Url = "";
  late String image3Url = "";
  late String webImageUrl = "";
  late String drawWinnerID = "";
  late String winningTicketID = "";
  late String drawStatus = "open"; //closed - open (def: open)
  late List<DrawTicket> tickets = [];

  User? winningUser;
  DrawTicket? winningTicket;

  ////
  ///

  Widget radioType() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Title(
            color: Colors.black,
            child: const Text("Draw Type",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
        const SizedBox(
          height: 5,
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.all(2),
          margin: const EdgeInsets.only(bottom: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: 150,
                child: ListTile(
                  title: const Text('FREE'),
                  leading: Radio(
                    value: 'free',
                    groupValue: drawType,
                    onChanged: (val) {
                      setState(() {
                        drawType = val.toString();
                      });
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 150,
                child: ListTile(
                  title: const Text('PRO'),
                  leading: Radio(
                    value: 'pro',
                    groupValue: drawType,
                    onChanged: (val) {
                      setState(() {
                        drawType = val.toString();
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  saveDraw() {
    if (_PromotionalDrawFormKey.currentState!.validate()) {
      String tempWinningTicketID = "";
      String tempWinningUserID = "";

      if (confirmedWinner) {
        tempWinningTicketID = winningTicketID;
        tempWinningUserID = drawWinnerID;
      }

      PromotionalDraw draw = PromotionalDraw.init(
          id: id,
          name: name,
          drawType: drawType,
          drawDate: drawDate,
          ticketsSold: ticketsSold,
          maxPerUserEntries: maxPerUserEntries,
          totalTicketsIssued: totalTicketsIssued,
          ticketPrice: ticketPrice,
          retailPrice: retailPrice,
          aboutOffer: aboutOffer,
          rules: rules,
          sponsorName: sponsorName,
          sponsorWhoWeAre: sponsorWhoWeAre,
          sponsorMission: sponsorMission,
          sponsorOrigin: sponsorOrigin,
          sponsorFindUs: sponsorFindUs,
          sponsorLink: sponsorLink,
          image1Url: image1Url,
          image2Url: image2Url,
          image3Url: image3Url,
          webImageUrl: webImageUrl,
          drawWinnerID: tempWinningUserID,
          winningTicketID: tempWinningTicketID,
          drawStatus: drawStatus,
          tickets: tickets);

      if (newDraw) {
        ref
            .read(drawStateProvider.notifier)
            .createNewPromotional(draw)
            .then((value) {
          Get.back();
        });
      } else {
        ref
            .read(drawStateProvider.notifier)
            .updatePromotionalDraw(oldDraw, draw)
            .then((value) {
          Get.back();
        });
      }
    } else {
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                title: Text("Not all required fields are filled"),
              ));
    }
  }

  fetchWinnerDetails(String ticketID) {
    setState(() {
      isLoading = true;
    });
    try {
      winningTicket = tickets.firstWhere((element) => element.id == ticketID);
      String userID = winningTicket!.userID;

      DBService _db = DBService();
      _db.fetchUser(userID).then((value) {
        if (value != null) {
          setState(() {
            isLoading = false;
            winningUser = value;
            winningTicketID = ticketID;
            drawWinnerID = userID;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage =
                "The user's information could not be found. Ticket invalid.";
          });
        }
      }).catchError((e) {
        print(e);
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage =
            "The user's information could not be found. Ticket invalid.";
      });
    }
  }

  String calculatedAge(String? dob) {
    if (dob != null && dob.length == 10) {
      int year = DateTime.now().year - int.parse(dob.substring(0, 4));
      return year.toString();
    } else {
      return "Unknown";
    }
  }

  @override
  void initState() {
    super.initState();
    PromotionalDraw? draw = ref.read(drawStateProvider).activeDraw;

    if (draw != null) {
      id = draw.id;
      name = draw.name;
      drawType = draw.drawType;
      drawDate = draw.drawDate;
      ticketsSold = draw.ticketsSold;
      maxPerUserEntries = draw.maxPerUserEntries;
      totalTicketsIssued = draw.totalTicketsIssued;
      ticketPrice = draw.ticketPrice;
      retailPrice = draw.retailPrice;
      aboutOffer = draw.aboutOffer;
      rules = draw.rules;
      sponsorName = draw.sponsorName;
      sponsorWhoWeAre = draw.sponsorWhoWeAre;
      sponsorMission = draw.sponsorMission;
      sponsorOrigin = draw.sponsorOrigin;
      sponsorFindUs = draw.sponsorFindUs;
      sponsorLink = draw.sponsorLink;
      image1Url = draw.image1Url;
      image2Url = draw.image2Url;
      image3Url = draw.image3Url;
      webImageUrl = draw.webImageUrl;
      drawWinnerID = draw.drawWinnerID;
      winningTicketID = draw.winningTicketID;
      drawStatus = draw.drawStatus;
      tickets = draw.tickets;

      newDraw = false;
      oldDraw = draw;

      if (draw.winningTicketID.isNotEmpty) {
        fetchWinnerDetails(draw.winningTicketID);
        setState(() {
          confirmedWinner = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    var datePicker = Row(
      children: [
        CustomTextField(
          "Draw Date & Time",
          (val) => {drawDate = val},
          initialValue: drawDate != null ? drawDate.toString() : null,
          readOnly: true,
          width: Get.width * 0.2,
        ),
        TextButton(
          onPressed: () {
            showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(DateTime.now().year + 2, DateTime.now().month,
                  DateTime.now().day),
            ).then((date) {
              if (date != null) {
                showTimePicker(context: context, initialTime: TimeOfDay.now())
                    .then((time) {
                  if (time != null) {
                    setState(() {
                      drawDate = DateTime(date.year, date.month, date.day,
                          time.hour, time.minute);
                    });
                  }
                });
              }
            });
          },
          child: const Text("Change"),
        )
      ],
    );
    return Scaffold(
      body: NavigationWidget(
        activePage: "Promotional Draw",
        titleOverride:
            newDraw ? "New Promotional Draw" : "Edit Promotional Draw",
        showSearchBar: false,
        actions: [
          ElevatedButton.icon(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              icon: const Icon(Icons.arrow_back),
              label: const Text("Back"),
              onPressed: () => Get.back()),
          const SizedBox(
            width: 20,
          ),
          ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: Text(newDraw ? "Create" : "Save"),
              onPressed: () => saveDraw())
        ],
        child: Stack(
          children: [
            Form(
              key: _PromotionalDrawFormKey,
              child: Stepper(
                  currentStep: _stepIndex,
                  type: StepperType.horizontal,
                  physics: const ClampingScrollPhysics(),
                  controlsBuilder: (_, details) => Row(
                        children: [
                          if (_stepIndex > 0)
                            ElevatedButton(
                                onPressed: details.onStepCancel,
                                child: const Text("Back")),
                          const SizedBox(
                            width: 10,
                          ),
                          if ((newDraw && _stepIndex != 2) ||
                              (!newDraw && _stepIndex != 3))
                            ElevatedButton(
                                onPressed: details.onStepContinue,
                                child: const Text("Continue"))
                          else
                            ElevatedButton(
                                onPressed: () => saveDraw(),
                                child: const Text("Save")),
                        ],
                      ),
                  onStepCancel: () {
                    if (_stepIndex > 0) {
                      setState(() {
                        _stepIndex -= 1;
                      });
                    }
                  },
                  onStepContinue: () {
                    if (_stepIndex <= 3) {
                      setState(() {
                        _stepIndex += 1;
                      });
                    }
                  },
                  onStepTapped: (int index) {
                    setState(() {
                      _stepIndex = index;
                    });
                  },
                  steps: [
                    Step(
                      isActive: _stepIndex == 0,
                      title: const Text("Draw Details"),
                      content: Card(
                        elevation: 8,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  radioType(),
                                  CustomTextField(
                                    "Ticket Price",
                                    (val) => {ticketPrice = val},
                                    initialValue: ticketPrice.toString(),
                                    onlyNumbers: true,
                                    allowDecimal: true,
                                    width: Get.width * 0.2,
                                    onChange: (val) =>
                                        ticketPrice = double.parse(val),
                                  ),
                                  CustomTextField(
                                    "Max Entries Per User",
                                    (val) => {maxPerUserEntries = val},
                                    initialValue: maxPerUserEntries.toString(),
                                    onlyNumbers: true,
                                    width: Get.width * 0.2,
                                    onChange: (val) =>
                                        maxPerUserEntries = int.parse(val),
                                  ),
                                ],
                              ),
                              CustomTextField(
                                "Draw Name",
                                (val) => {name = val},
                                initialValue: name,
                                onChange: (val) => name = val,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomTextField(
                                    "Retail Price",
                                    (val) => {retailPrice = val},
                                    initialValue:
                                        retailPrice.toStringAsFixed(2),
                                    onlyNumbers: true,
                                    allowDecimal: true,
                                    width: Get.width * 0.2,
                                    onChange: (val) =>
                                        retailPrice = double.parse(val),
                                  ),
                                  CustomTextField(
                                    "Total Tickets Issued",
                                    (val) => {totalTicketsIssued = val},
                                    initialValue: totalTicketsIssued.toString(),
                                    onlyNumbers: true,
                                    width: Get.width * 0.2,
                                    onChange: (val) =>
                                        totalTicketsIssued = int.parse(val),
                                  ),
                                  CustomTextField(
                                    "Total Tickets Bought",
                                    (val) => {ticketsSold = val},
                                    initialValue: ticketsSold.toString(),
                                    onlyNumbers: true,
                                    width: Get.width * 0.2,
                                    readOnly: true,
                                  ),
                                ],
                              ),
                              datePicker,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Step(
                      isActive: _stepIndex == 1,
                      title: const Text("Promotional Info"),
                      content: Card(
                        elevation: 8,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextField(
                                "About the Offer (1000 Characters Max)",
                                (val) => {aboutOffer = val},
                                initialValue: aboutOffer,
                                maxLength: 1000,
                                onChange: (val) => aboutOffer = val,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  'Rules',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              DrawRuleInputs(rule: rules),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 2),
                                padding: const EdgeInsets.all(10),
                                width: double.infinity,
                                color: Colors.grey.shade100,
                                child: const Text.rich(
                                  TextSpan(
                                    text:
                                        "For more rules, Terms and Conditions please read the full ",
                                    children: [
                                      TextSpan(
                                          text: "Terms Agreement",
                                          style: TextStyle(color: Colors.blue)),
                                      TextSpan(text: " and"),
                                      TextSpan(
                                          text: " Privacy Policy Agreement",
                                          style: TextStyle(color: Colors.blue)),
                                      TextSpan(text: " on our website"),
                                    ],
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  'Sponsor Details',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              CustomTextField(
                                "Sponsor Name",
                                (val) => {sponsorName = val},
                                initialValue: sponsorName,
                                onChange: (val) => sponsorName = val,
                              ),
                              CustomTextField(
                                "Who We Are (500 Characters Max)",
                                (val) => {sponsorWhoWeAre = val},
                                initialValue: sponsorWhoWeAre,
                                maxLength: 500,
                                notRequired: true,
                                onChange: (val) => sponsorWhoWeAre = val,
                              ),
                              CustomTextField(
                                "Our Mission (500 Characters Max)",
                                (val) => {sponsorMission = val},
                                initialValue: sponsorMission,
                                maxLength: 500,
                                notRequired: true,
                                onChange: (val) => sponsorMission = val,
                              ),
                              CustomTextField(
                                "Our Origin (500 Characters Max)",
                                (val) => {sponsorOrigin = val},
                                initialValue: sponsorOrigin,
                                maxLength: 500,
                                notRequired: true,
                                onChange: (val) => sponsorOrigin = val,
                              ),
                              CustomTextField(
                                "Where to Find Us (500 Characters Max)",
                                (val) => {sponsorFindUs = val},
                                initialValue: sponsorFindUs,
                                maxLength: 500,
                                notRequired: true,
                                onChange: (val) => sponsorFindUs = val,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Step(
                      isActive: _stepIndex == 2,
                      title: const Text("Media & Link"),
                      content: Card(
                        elevation: 8,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  'Draw Images (Max 3)',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Wrap(
                                alignment: WrapAlignment.center,
                                children: [
                                  DrawMediaInputs(
                                    imageURL: image1Url,
                                    updateImage: (val) {
                                      setState(() {
                                        image1Url = val;
                                      });
                                    },
                                    deleteImage: () {
                                      setState(() {
                                        image1Url = "";
                                      });
                                    },
                                  ),
                                  DrawMediaInputs(
                                    imageURL: image2Url,
                                    updateImage: (val) {
                                      setState(() {
                                        image2Url = val;
                                      });
                                    },
                                    deleteImage: () {
                                      setState(() {
                                        image2Url = "";
                                      });
                                    },
                                  ),
                                  DrawMediaInputs(
                                    imageURL: image3Url,
                                    updateImage: (val) {
                                      setState(() {
                                        image3Url = val;
                                      });
                                    },
                                    deleteImage: () {
                                      setState(() {
                                        image3Url = "";
                                      });
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  CustomTextField(
                                    "Sponsor Link",
                                    (val) => {sponsorLink = val},
                                    initialValue: sponsorLink,
                                    width: Get.width * 0.3,
                                    onChange: (val) => sponsorLink = val,
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  DrawMediaInputs(
                                    imageURL: webImageUrl,
                                    updateImage: (val) {
                                      setState(() {
                                        webImageUrl = val;
                                      });
                                    },
                                    deleteImage: () {
                                      setState(() {
                                        webImageUrl = "";
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (!newDraw)
                      Step(
                        isActive: _stepIndex == 3,
                        title: const Text("Pick Winner"),
                        content: Card(
                          elevation: 8,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Column(
                                    children: [
                                      Title(
                                          color: Colors.black,
                                          child: const Text(
                                              "Select winning number",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                        key: UniqueKey(),
                                        decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        margin:
                                            const EdgeInsets.only(bottom: 20),
                                        child: DropdownButton(
                                          value: winningTicketID.isEmpty
                                              ? null
                                              : winningTicketID,
                                          alignment: Alignment.center,
                                          items: tickets
                                              .map((ticket) => DropdownMenuItem(
                                                    child: Text(
                                                      "#${ticket.ticketNumber} (code: ${ticket.id})",
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    value: ticket.id,
                                                  ))
                                              .toList(),
                                          onChanged: confirmedWinner
                                              ? null
                                              : (val) {
                                                  fetchWinnerDetails(
                                                      val.toString());
                                                },
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      if (winningUser != null)
                                        CustomDataTable(
                                          pageIndex: 0,
                                          onPrevious: (firstVal) => 0,
                                          onNext: (lastVal) => 0,
                                          dataReady: !isLoading,
                                          dataColumns: const [
                                            'Ticket No.',
                                            'Name',
                                            'Email',
                                            'Date Entered',
                                            'Gender',
                                            'Age',
                                            'Plan'
                                          ],
                                          lastVal: "",
                                          dataRows: [
                                            DataRow(cells: [
                                              DataCell(Text(
                                                  "#${winningTicket!.ticketNumber} ($winningTicketID)")),
                                              DataCell(
                                                  Text("${winningUser!.name}")),
                                              DataCell(Text(
                                                  "${winningUser!.email}")),
                                              DataCell(Text(customDateFormat
                                                  .format(winningTicket!
                                                      .purchaseDate))),
                                              DataCell(Text(
                                                  "${winningUser!.gender}")),
                                              DataCell(Text(calculatedAge(
                                                  winningUser!.dateOfBirth))),
                                              const DataCell(Text("TEmp")),
                                            ])
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                if (winningTicketID.isNotEmpty)
                                  SizedBox(
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            ElevatedButton.icon(
                                                icon: const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                ),
                                                label: const Text(
                                                  "Confirm Winner",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(confirmedWinner
                                                                ? Colors
                                                                    .green[100]
                                                                : Colors
                                                                    .green)),
                                                onPressed: confirmedWinner
                                                    ? null
                                                    : () {
                                                        setState(() {
                                                          confirmedWinner =
                                                              true;
                                                        });
                                                      }),
                                            if (confirmedWinner)
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(4),
                                                decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.blue),
                                                child: IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        confirmedWinner = false;
                                                        winningUser = null;
                                                        winningTicketID = "";
                                                        drawWinnerID = "";
                                                      });
                                                    },
                                                    icon: const Icon(
                                                      Icons.refresh,
                                                      color: Colors.white,
                                                    )),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        ElevatedButton.icon(
                                            icon: const Icon(
                                              Icons.flag,
                                              color: Colors.white,
                                            ),
                                            label: const Text(
                                              "Close Draw",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        confirmedWinner
                                                            ? Colors.red
                                                            : Colors.red[200])),
                                            onPressed: confirmedWinner
                                                ? () {
                                                    setState(() {
                                                      drawStatus = "closed";
                                                      saveDraw();
                                                    });
                                                  }
                                                : null),
                                      ],
                                    ),
                                  ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Text(
                                    "Note: Once winner is confirmed and draw is closed, no changes may be made and draw can not be deleted",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                  ]),
            ),
            if (ref.read(drawStateProvider).isLoading)
              LayoutBuilder(builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth,
                  height: screenSize.height * 0.8,
                  color: Colors.black.withOpacity(0.4),
                  child: const Center(
                    child: SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator()),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
