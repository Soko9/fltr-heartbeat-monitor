class User {
  final int id;
  String name;
  int age;
  int emergencyNumber;
  String isAthlete;
  // Disease disease = Disease.none;

  User({
    required this.id,
    required this.name,
    required this.age,
    required this.emergencyNumber,
    required this.isAthlete,
    // required this.disease,
  });

  User.fromMap(Map<String, dynamic> user)
      : id = user['id'],
        name = user['name'],
        age = user['age'],
        emergencyNumber = user['emergencyNumber'],
        isAthlete = user['isAthlete'];
  // disease = user['disease'];

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'age': age,
        'emergencyNumber': emergencyNumber,
        'isAthlete': isAthlete,
        // 'disease': disease,
      };

  setName(String newName) => name = newName;
  setAge(int newAge) => age = newAge;
  setEmergencyNumber(int newEmergencyNumber) =>
      emergencyNumber = newEmergencyNumber;
  setIsAthlete(bool newIsAthlete) => isAthlete = newIsAthlete.toString();
  // setDisease(Disease disease) => disease = disease;

  Map<String, int> getBPMRange() {
    int ageNow = DateTime.now().year - age;
    if (isAthlete == "true") {
      return {
        'min': 40,
        'max': 60,
        'bound': 180,
      };
    } else if (ageNow >= 3 && ageNow <= 4) {
      return {
        'min': 80,
        'max': 120,
        'bound': 180,
      };
    } else if (ageNow >= 5 && ageNow <= 6) {
      return {
        'min': 75,
        'max': 115,
        'bound': 180,
      };
    } else if (ageNow >= 7 && ageNow <= 9) {
      return {
        'min': 70,
        'max': 110,
        'bound': 180,
      };
    } else if (ageNow >= 10 && ageNow <= 19) {
      return {
        'min': 60,
        'max': 100,
        'bound': 180,
      };
    } else if (ageNow >= 20 && ageNow <= 29) {
      int bound = 200;
      return {
        'min': (bound * 0.5).toInt(),
        'max': (bound * 0.85).toInt(),
        'bound': bound,
      };
    } else if (ageNow >= 30 && ageNow <= 35) {
      int bound = 190;
      return {
        'min': (bound * 0.5).toInt(),
        'max': (bound * 0.85).toInt(),
        'bound': bound,
      };
    } else if (ageNow >= 36 && ageNow <= 39) {
      int bound = 185;
      return {
        'min': (bound * 0.5).toInt(),
        'max': (bound * 0.85).toInt(),
        'bound': bound,
      };
    } else if (ageNow >= 40 && ageNow <= 45) {
      int bound = 180;
      return {
        'min': (bound * 0.5).toInt(),
        'max': (bound * 0.85).toInt(),
        'bound': bound,
      };
    } else if (ageNow >= 46 && ageNow <= 49) {
      int bound = 175;
      return {
        'min': (bound * 0.5).toInt(),
        'max': (bound * 0.85).toInt(),
        'bound': bound,
      };
    } else if (ageNow >= 50 && ageNow <= 55) {
      int bound = 170;
      return {
        'min': (bound * 0.5).toInt(),
        'max': (bound * 0.85).toInt(),
        'bound': bound,
      };
    } else if (ageNow >= 56 && ageNow <= 59) {
      int bound = 165;
      return {
        'min': (bound * 0.5).toInt(),
        'max': (bound * 0.85).toInt(),
        'bound': bound,
      };
    } else if (ageNow >= 60 && ageNow <= 65) {
      int bound = 160;
      return {
        'min': (bound * 0.5).toInt(),
        'max': (bound * 0.85).toInt(),
        'bound': bound,
      };
    } else if (ageNow >= 66 && ageNow <= 69) {
      int bound = 155;
      return {
        'min': (bound * 0.5).toInt(),
        'max': (bound * 0.85).toInt(),
        'bound': bound,
      };
    } else {
      int bound = 150;
      return {
        'min': (bound * 0.5).toInt(),
        'max': (bound * 0.85).toInt(),
        'bound': bound,
      };
    }
  }
}
