class NoteModel {
  int? phone;
  String? name;
  String? address;

  NoteModel({
    this.phone,
    this.name,
    this.address,
  });

  NoteModel.fromJson(Map<String, dynamic> map) {
    phone = map['phone'];
    name = map['name'];
    address = map['address'];
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'name': name,
      'address': address,
    };
  }
}

