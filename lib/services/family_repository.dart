import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/family_member.dart';
import '../models/verification_and_document.dart';

class FamilyRepository extends ChangeNotifier {
  User? _currentUser;
  final List<FamilyMember> _members = [];
  final List<VerificationRequest> _verifications = [];
  final List<OfficialDocument> _documents = [];

  User? get currentUser => _currentUser;
  List<FamilyMember> get members => List.unmodifiable(_members);
  List<VerificationRequest> get verifications => List.unmodifiable(_verifications);
  List<OfficialDocument> get documents => List.unmodifiable(_documents);

  FamilyRepository() {
    _initMockData();
  }

  void _initMockData() {
    // Grand-père
    final grandFather = FamilyMember(
      id: 'm1',
      firstName: 'عبد الله',
      fatherName: 'محمد',
      grandFatherName: 'علي',
      familyName: 'الجزائري',
      gender: Gender.male,
      birthDate: '1940-05-12',
      birthPlace: 'الجزائر العاصمة',
      status: VerificationStatus.verified,
      childrenIds: ['m2', 'm3'],
    );

    // Père
    final father = FamilyMember(
      id: 'm2',
      firstName: 'أحمد',
      fatherName: 'عبد الله',
      grandFatherName: 'محمد',
      familyName: 'الجزائري',
      gender: Gender.male,
      birthDate: '1968-08-20',
      birthPlace: 'الجزائر العاصمة',
      fatherId: 'm1',
      spouseId: 'm4',
      status: VerificationStatus.verified,
      childrenIds: ['m5'],
    );

    // Oncle
    final uncle = FamilyMember(
      id: 'm3',
      firstName: 'عمر',
      fatherName: 'عبد الله',
      grandFatherName: 'محمد',
      familyName: 'الجزائري',
      gender: Gender.male,
      birthDate: '1972-11-15',
      birthPlace: 'الجزائر العاصمة',
      fatherId: 'm1',
      status: VerificationStatus.underVerification,
    );

    // Mère
    final mother = FamilyMember(
      id: 'm4',
      firstName: 'فاطمة',
      fatherName: 'سليمان',
      grandFatherName: 'إبراهيم',
      familyName: 'البلوشي',
      gender: Gender.female,
      birthDate: '1972-02-10',
      birthPlace: 'وهران',
      spouseId: 'm2',
      status: VerificationStatus.verified,
      childrenIds: ['m5'],
    );

    // Fils (Utilisateur connecté par exemple)
    final me = FamilyMember(
      id: 'm5',
      firstName: 'يوسف',
      fatherName: 'أحمد',
      grandFatherName: 'عبد الله',
      familyName: 'الجزائري',
      gender: Gender.male,
      birthDate: '1998-04-03',
      birthPlace: 'الجزائر العاصمة',
      fatherId: 'm2',
      motherId: 'm4',
      status: VerificationStatus.verified,
    );

    _members.addAll([grandFather, father, uncle, mother, me]);

    _currentUser = User(
      id: 'u1',
      email: 'youssef@example.com',
      name: 'يوسف الجزائري',
      role: UserRole.member,
      linkedMemberId: 'm5',
    );

    _verifications.add(
      VerificationRequest(
        id: 'v1',
        targetMemberId: 'm3',
        requesterId: 'u1',
        description: 'تأكيد معلومات العم عمر وتاريخ الميلاد الرسمي',
        approvalsCount: 2,
        rejectionsCount: 0,
      ),
    );

    _documents.add(
      OfficialDocument(
        id: 'd1',
        memberId: 'm1',
        type: DocumentType.birthCertificate,
        title: 'شهادة ميلاد الجد عبد الله',
        fileUrl: 'https://example.com/doc1.pdf',
        isVerified: true,
      ),
    );
  }

  bool login(String email, String password) {
    if (email.isNotEmpty && password.isNotEmpty) {
      _currentUser = User(
        id: 'u1',
        email: email,
        name: 'يوسف الجزائري',
        role: UserRole.member,
        linkedMemberId: 'm5',
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void addMember(FamilyMember member) {
    _members.add(member);
    // Auto-update links if father/mother/spouse set
    if (member.fatherId != null) {
      final fatherIndex = _members.indexWhere((m) => m.id == member.fatherId);
      if (fatherIndex != -1) {
        final father = _members[fatherIndex];
        final updatedChildren = List<String>.from(father.childrenIds)..add(member.id);
        _members[fatherIndex] = FamilyMember(
          id: father.id,
          firstName: father.firstName,
          fatherName: father.fatherName,
          grandFatherName: father.grandFatherName,
          familyName: father.familyName,
          gender: father.gender,
          birthDate: father.birthDate,
          birthPlace: father.birthPlace,
          isAlive: father.isAlive,
          deathDate: father.deathDate,
          biography: father.biography,
          status: father.status,
          fatherId: father.fatherId,
          motherId: father.motherId,
          spouseId: father.spouseId,
          childrenIds: updatedChildren,
        );
      }
    }
    notifyListeners();
  }

  void voteVerification(String requestId, bool approve) {
    final index = _verifications.indexWhere((v) => v.id == requestId);
    if (index != -1) {
      final request = _verifications[index];
      if (approve) {
        request.approvalsCount++;
      } else {
        request.rejectionsCount++;
      }
      if (request.approvalsCount >= 3) {
        request.status = VerificationRequestStatus.approved;
        // Update member status
        final memberIndex = _members.indexWhere((m) => m.id == request.targetMemberId);
        if (memberIndex != -1) {
          final m = _members[memberIndex];
          _members[memberIndex] = FamilyMember(
            id: m.id,
            firstName: m.firstName,
            fatherName: m.fatherName,
            grandFatherName: m.grandFatherName,
            familyName: m.familyName,
            gender: m.gender,
            birthDate: m.birthDate,
            birthPlace: m.birthPlace,
            isAlive: m.isAlive,
            deathDate: m.deathDate,
            biography: m.biography,
            status: VerificationStatus.verified,
            fatherId: m.fatherId,
            motherId: m.motherId,
            spouseId: m.spouseId,
            childrenIds: m.childrenIds,
          );
        }
      }
      notifyListeners();
    }
  }

  void addDocument(OfficialDocument document) {
    _documents.add(document);
    notifyListeners();
  }
}
