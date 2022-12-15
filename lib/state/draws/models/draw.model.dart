import 'package:smartgolfportal/state/draws/models/draw_ticket.modal.dart';

class PromotionalDraw {
  late String id;
  late String name;
  late String drawType; //free - pro (def: pro)
  late DateTime? drawDate;
  late int ticketsSold;
  late int maxPerUserEntries;
  late int totalTicketsIssued;
  late double ticketPrice;
  late double retailPrice;
  late String aboutOffer;
  late List<String> rules;
  late String sponsorName;
  late String sponsorWhoWeAre;
  late String sponsorMission;
  late String sponsorOrigin;
  late String sponsorFindUs;
  late String sponsorLink;
  late String image1Url;
  late String image2Url;
  late String image3Url;
  late String webImageUrl;
  late String drawWinnerID;
  late String winningTicketID;
  late String drawStatus; //closed - open (def: open)
  late List<DrawTicket> tickets;

  PromotionalDraw([input, key]) {
    try {
      name = input?['name'] ?? "";
      id = input?['id'] ?? key;
      drawType = input?['drawType'] ?? "";
      drawDate = input?['drawDate'] != null
          ? DateTime.parse(input?['drawDate'])
          : null;
      ticketsSold = int.parse(input?['ticketsSold'].toString() ?? "0");
      maxPerUserEntries =
          int.parse(input?['maxPerUserEntries'].toString() ?? "0");
      totalTicketsIssued =
          int.parse(input?['totalTicketsIssued'].toString() ?? "0");
      ticketPrice = double.parse(input?['ticketPrice'].toString() ?? "0");
      retailPrice = double.parse(input?['retailPrice'].toString() ?? "0");
      aboutOffer = input?['aboutOffer'] ?? "";
      rules = input?['rules'] != null
          ? input['rules'].map<String>((text) => text.toString()).toList()
          : [];
      sponsorName = input?['sponsorName'] ?? "";
      sponsorWhoWeAre = input?['sponsorWhoWeAre'] ?? "";
      sponsorMission = input?['sponsorMission'] ?? "";
      sponsorOrigin = input?['sponsorOrigin'] ?? "";
      sponsorFindUs = input?['sponsorFindUs'] ?? "";
      sponsorLink = input?['sponsorLink'] ?? "";
      image1Url = input?['image1Url'] ?? "";
      image2Url = input?['image2Url'] ?? "";
      image3Url = input?['image3Url'] ?? "";
      webImageUrl = input?['webImageUrl'] ?? "";
      drawWinnerID = input?['drawWinnerID'] ?? "";
      winningTicketID = input?['winningTicketID'] ?? "";
      drawStatus = input?['drawStatus'] ?? "";

      if (input?['tickets'] != null) {
        Map values = input?['tickets'];
        List<DrawTicket> tempTickets = [];

        values.forEach((key, value) {
          DrawTicket ticket = DrawTicket(value, key);
          tempTickets.add(ticket);
        });
        tickets = tempTickets;
      } else {
        tickets = [];
      }
    } catch (e) {
      print("PROMO DRAW MODEL ERROR: $e");
    }
  }

  PromotionalDraw.init(
      {required this.id,
      required this.name,
      required this.drawType,
      required this.drawDate,
      required this.ticketsSold,
      required this.maxPerUserEntries,
      required this.totalTicketsIssued,
      required this.ticketPrice,
      required this.retailPrice,
      required this.aboutOffer,
      required this.rules,
      required this.sponsorName,
      required this.sponsorWhoWeAre,
      required this.sponsorMission,
      required this.sponsorOrigin,
      required this.sponsorFindUs,
      required this.sponsorLink,
      required this.image1Url,
      required this.image2Url,
      required this.image3Url,
      required this.webImageUrl,
      required this.drawWinnerID,
      required this.winningTicketID,
      required this.drawStatus,
      required this.tickets});

  getJson() {
    return {
      'id': id,
      'name': name,
      'drawType': drawType,
      'drawDate': drawDate.toString(),
      'ticketsSold': ticketsSold,
      'maxPerUserEntries': maxPerUserEntries,
      'totalTicketsIssued': totalTicketsIssued,
      'ticketPrice': ticketPrice,
      'retailPrice': retailPrice,
      'aboutOffer': aboutOffer,
      'rules': rules,
      'sponsorName': sponsorName,
      'sponsorWhoWeAre': sponsorWhoWeAre,
      'sponsorMission': sponsorMission,
      'sponsorOrigin': sponsorOrigin,
      'sponsorFindUs': sponsorFindUs,
      'sponsorLink': sponsorLink,
      'image1Url': image1Url,
      'image2Url': image2Url,
      'image3Url': image3Url,
      'webImageUrl': webImageUrl,
      'drawWinnerID': drawWinnerID,
      'winningTicketID': winningTicketID,
      'drawStatus': drawStatus,
    };
  }
}
