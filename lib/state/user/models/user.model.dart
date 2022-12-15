class User {
  String? name;
  String? id;
  String? dateOfBirth;
  String? email;
  String? gender;
  String? imageUrl;
  String? type;
  String? plan;

  User([input]) {
    name = input?['name'];
    id = input?['id'];
    dateOfBirth = input?['dateOfBirth'];
    email = input?['email'];
    gender = input?['gender'];
    imageUrl = input?['imageUrl'];
    type = input?['type'];
    plan = input?['plan'] ?? "free";
  }

  getAge() {
    if (dateOfBirth != null && dateOfBirth!.length == 10) {
      int year = DateTime.now().year - int.parse(dateOfBirth!.substring(0, 4));
      return year.toString();
    } else {
      return "Unknown";
    }
  }

  getJson() {
    return {
      'name': name,
      'id': id,
      'dateOfBirth': dateOfBirth,
      'email': email,
      'imageUrl': imageUrl,
      'type': type,
      'plan': plan,
    };
  }
}
