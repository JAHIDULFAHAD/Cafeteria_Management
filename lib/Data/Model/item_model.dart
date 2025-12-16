class ItemModel {
  final String id;    // Firestore document ID
  final String uid;   // User ID (যার জন্য item তৈরি হয়েছে)
  final String name;  // Item name

  ItemModel({
    required this.id,
    required this.uid,
    required this.name,
  });

  // Convert ItemModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
    };
  }

  // Create ItemModel from Firestore doc
  factory ItemModel.fromDoc(String id, Map<String, dynamic> data) {
    return ItemModel(
      id: id,
      uid: data["uid"] ?? "",
      name: data["name"] ?? "",
    );
  }
}
