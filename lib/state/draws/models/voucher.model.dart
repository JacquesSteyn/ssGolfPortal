class Voucher {
  late String id;
  late String voucherName;
  late String voucherStatus; // Active, Complete, Expired, Canceled
  late String voucherNumber;
  late double voucherPrice;
  late int voucherAllowedEntries;
  late DateTime? voucherExpireDate;
  late List<RedeemedVoucher> redeemedVouchers;

  Voucher([input, key]) {
    try {
      id = input?['id'] ?? "";
      voucherName = input?['voucherName'] ?? "";
      voucherStatus = input?['voucherStatus'] ?? "";
      voucherNumber = input?['voucherNumber'] ?? "";
      voucherPrice = double.parse(input?['voucherPrice'].toString() ?? "0");
      voucherAllowedEntries =
          int.parse(input?['voucherAllowedEntries'].toString() ?? "0");
      voucherExpireDate = input?['voucherExpireDate'] != null
          ? DateTime.parse(input?['voucherExpireDate'])
          : null;

      if (input?['redeemedVouchers'] != null) {
        Map values = input?['redeemedVouchers'];
        List<RedeemedVoucher> tempRedemptions = [];

        values.forEach((key, value) {
          RedeemedVoucher ticket = RedeemedVoucher(value, key);
          tempRedemptions.add(ticket);
        });
        redeemedVouchers = tempRedemptions;
      } else {
        redeemedVouchers = [];
      }
    } catch (e) {
      print("VOUCHER MODEL ERROR: $e");
    }
  }

  Voucher.init(
      {required this.id,
      required this.voucherName,
      required this.voucherStatus,
      required this.voucherNumber,
      required this.voucherPrice,
      required this.voucherAllowedEntries,
      required this.voucherExpireDate,
      required this.redeemedVouchers});

  getJson() {
    return {
      'id': id,
      'voucherName': voucherName,
      'voucherStatus': voucherStatus,
      'voucherNumber': voucherNumber,
      'voucherPrice': voucherPrice,
      'voucherAllowedEntries': voucherAllowedEntries,
      'voucherExpireDate': voucherExpireDate.toString(),
      'redeemedVouchers': redeemedVouchers,
    };
  }
}

class RedeemedVoucher {
  late String id;
  late String userID;
  late DateTime? redeemedDate;

  RedeemedVoucher([input, key]) {
    try {
      id = input?['id'] ?? "";
      userID = input?['userID'] ?? "";
      redeemedDate = input?['redeemedDate'] != null
          ? DateTime.parse(input?['redeemedDate'])
          : null;
    } catch (e) {
      print('REDEEMED VOUCHER ERROR: $e');
    }
  }

  getJson() {
    return {
      'id': id,
      'userID': userID,
      'redeemedDate': redeemedDate.toString(),
    };
  }
}
