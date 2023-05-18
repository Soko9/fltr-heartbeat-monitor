class Session {
  final int id;
  final String dateTime;
  final int bpm;
  final int userID;

  Session({
    required this.id,
    required this.dateTime,
    required this.bpm,
    required this.userID,
  });

  Session.fromMap(Map<String, dynamic> session)
      : id = session['id'],
        dateTime = session['dateTime'],
        bpm = session['bpm'],
        userID = session['userID'];

  Map<String, dynamic> toMap() => {
        'id': id,
        'dateTime': dateTime,
        'bpm': bpm,
        'userID': userID,
      };
}
