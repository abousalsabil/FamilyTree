enum VerificationRequestStatus { pending, approved, rejected }

class VerificationRequest {
  final String id;
  final String targetMemberId;
  final String requesterId;
  final String description;
  int approvalsCount;
  int rejectionsCount;
  VerificationRequestStatus status;

  VerificationRequest({
    required this.id,
    required this.targetMemberId,
    required this.requesterId,
    required this.description,
    this.approvalsCount = 0,
    this.rejectionsCount = 0,
    this.status = VerificationRequestStatus.pending,
  });
}

enum DocumentType { birthCertificate, familyBook, identityCard, archive }

class OfficialDocument {
  final String id;
  final String memberId;
  final DocumentType type;
  final String title;
  final String fileUrl;
  final bool isVerified;

  OfficialDocument({
    required this.id,
    required this.memberId,
    required this.type,
    required this.title,
    required this.fileUrl,
    this.isVerified = false,
  });
}
