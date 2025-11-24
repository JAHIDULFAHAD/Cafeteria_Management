class StaffModel {
  final String id;
  String name;
  double salary; // Base salary
  double pendingSalary;

  StaffModel({
    required this.id,
    required this.name,
    required this.salary,
    this.pendingSalary = 0,
  });
}
