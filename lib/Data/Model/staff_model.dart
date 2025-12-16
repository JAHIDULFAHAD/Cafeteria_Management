class StaffModel {
  final String id;       // Firestore document ID
  final String uid;      // Firebase User ID
  String name;
  double salary;         // Base salary
  double pendingSalary;

  StaffModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.salary,
    this.pendingSalary = 0,
  });

  /// Convert to Map for Firestore (don't include `id`, Firestore doc ID used instead)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'salary': salary,
      'pendingSalary': pendingSalary,
    };
  }

  /// Create StaffModel from Firestore document
  factory StaffModel.fromFirestore(String docId, Map<String, dynamic> map) {
    return StaffModel(
      id: docId,
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      salary: (map['salary'] ?? 0).toDouble(),
      pendingSalary: (map['pendingSalary'] ?? 0).toDouble(),
    );
  }
}
