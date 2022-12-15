class Result {
  late String percentage;
  late List inputResults;
  late String id;
  late DateTime dateTimeCreated;

  Result([input]) {
    id = input?['id'];
    percentage = input?['percentage'];
    inputResults = input?['inputResults'];
    dateTimeCreated = input?['dateTimeCreated'];
  }
}
