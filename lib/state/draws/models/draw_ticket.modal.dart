class DrawTicket {
  late String id;
  late String ticketNumber;
  late String drawID;
  late String userID;
  late String userName;
  late DateTime purchaseDate;

  DrawTicket([data, id]) {
    try {
      if (data != null) {
        this.id = id;
        ticketNumber = data['ticketNumber'] ?? "Unknown";
        drawID = data['drawID'];
        userID = data['userID'];
        userName = data['userName'];
        purchaseDate = DateTime.parse(data['purchaseDate']);
      }
    } catch (e) {
      print("CREATING TICKET ERROR -> $e");
    }
  }

  DrawTicket.empty();

  DrawTicket.init(
      {required this.drawID,
      required this.userID,
      required this.userName,
      required this.purchaseDate});

  getJson() {
    return {
      'id': id,
      'drawID': drawID,
      'userID': userID,
      'userName': userName,
      'purchaseDate': purchaseDate.toString(),
    };
  }
}
