class StaffModel {
  final String id;
  String name;
  double salary; // Base salary
  double pendingSalary; // পরের মাসের বকেয়া

  StaffModel({
    required this.id,
    required this.name,
    required this.salary,
    this.pendingSalary = 0,
  });
}
