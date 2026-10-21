enum VerificationStatus { declarative, underVerification, verified }

enum Gender { male, female }

class FamilyMember {
  final String id;
  final String firstName;
  final String fatherName;
  final String grandFatherName;
  final String familyName;
  final Gender gender;
  final String? birthDate;
  final String? birthPlace;
  final bool isAlive;
  final String? deathDate;
  final String? biography;
  final VerificationStatus status;
  final String? fatherId;
  final String? motherId;
  final String? spouseId;
  final List<String> childrenIds;

  FamilyMember({
    required this.id,
    required this.firstName,
    required this.fatherName,
    required this.grandFatherName,
    required this.familyName,
    required this.gender,
    this.birthDate,
    this.birthPlace,
    this.isAlive = true,
    this.deathDate,
    this.biography,
    this.status = VerificationStatus.declarative,
    this.fatherId,
    this.motherId,
    this.spouseId,
    this.childrenIds = const [],
  });

  String get fullName => '$firstName $fatherName $grandFatherName $familyName';

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      fatherName: json['fatherName'] as String,
      grandFatherName: json['grandFatherName'] as String,
      familyName: json['familyName'] as String,
      gender: Gender.values.firstWhere(
        (e) => e.name == json['gender'],
        orElse: () => Gender.male,
      ),
      birthDate: json['birthDate'] as String?,
      birthPlace: json['birthPlace'] as String?,
      isAlive: json['isAlive'] as bool? ?? true,
      deathDate: json['deathDate'] as String?,
      biography: json['biography'] as String?,
      status: VerificationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => VerificationStatus.declarative,
      ),
      fatherId: json['fatherId'] as String?,
      motherId: json['motherId'] as String?,
      spouseId: json['spouseId'] as String?,
      childrenIds: (json['childrenIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'fatherName': fatherName,
      'grandFatherName': grandFatherName,
      'familyName': familyName,
      'gender': gender.name,
      'birthDate': birthDate,
      'birthPlace': birthPlace,
      'isAlive': isAlive,
      'deathDate': deathDate,
      'biography': biography,
      'status': status.name,
      'fatherId': fatherId,
      'motherId': motherId,
      'spouseId': spouseId,
      'childrenIds': childrenIds,
    };
  }
}
