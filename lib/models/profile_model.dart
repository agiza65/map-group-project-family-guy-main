class ProfileModel {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String contact;
  final String email;
  final String notes;
  final String? photoUrl;
  final List<String> bloodUrls;
  final List<String> urineUrls;
  final List<String> historyUrls;

  ProfileModel({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.contact,
    required this.email,
    required this.notes,
    required this.photoUrl,
    required this.bloodUrls,
    required this.urineUrls,
    required this.historyUrls,
  });

  factory ProfileModel.fromMap(String id, Map<String, dynamic> map) {
    return ProfileModel(
      id: id,
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      gender: map['gender'] ?? 'Male',
      contact: map['contact'] ?? '',
      email: map['email'] ?? '',
      notes: map['notes'] ?? '',
      photoUrl: map['photoUrl'],
      bloodUrls: List<String>.from(map['bloodUrls'] ?? []),
      urineUrls: List<String>.from(map['urineUrls'] ?? []),
      historyUrls: List<String>.from(map['historyUrls'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'contact': contact,
      'email': email,
      'notes': notes,
      'photoUrl': photoUrl,
      'bloodUrls': bloodUrls,
      'urineUrls': urineUrls,
      'historyUrls': historyUrls,
    };
  }
}
