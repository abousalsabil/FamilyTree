import 'package:flutter/material.dart';
import '../models/family_member.dart';
import '../services/family_repository.dart';

class InteractiveTreeWidget extends StatelessWidget {
  final FamilyRepository repository;
  final Function(FamilyMember) onMemberTap;

  const InteractiveTreeWidget({
    super.key,
    required this.repository,
    required this.onMemberTap,
  });

  @override
  Widget build(BuildContext context) {
    final members = repository.members;

    // Find roots (members without father in dataset)
    final roots = members.where((m) => m.fatherId == null).toList();

    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(200),
      minScale: 0.2,
      maxScale: 3.0,
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: roots.map((root) => _buildMemberNode(context, root, members)).toList(),
        ),
      ),
    );
  }

  Widget _buildMemberNode(BuildContext context, FamilyMember member, List<FamilyMember> allMembers) {
    final children = allMembers.where((m) => m.fatherId == member.id || m.motherId == member.id).toList();

    return Column(
      children: [
        GestureDetector(
          onTap: () => onMemberTap(member),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: member.gender == Gender.male ? Colors.blue.shade50 : Colors.pink.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: member.status == VerificationStatus.verified
                    ? Colors.green
                    : (member.status == VerificationStatus.underVerification ? Colors.orange : Colors.grey),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor: member.gender == Gender.male ? Colors.blue : Colors.pink,
                  child: Icon(
                    member.gender == Gender.male ? Icons.person : Icons.person_2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    if (member.birthDate != null)
                      Text(
                        'ولد: ${member.birthDate}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                _buildStatusChip(member.status),
              ],
            ),
          ),
        ),
        if (children.isNotEmpty) ...[
          Container(
            width: 2,
            height: 24,
            color: Colors.teal.shade300,
          ),
          Container(
            padding: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.teal.shade300, width: 2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children.map((child) => _buildMemberNode(context, child, allMembers)).toList(),
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildStatusChip(VerificationStatus status) {
    Color color;
    String label;
    switch (status) {
      case VerificationStatus.verified:
        color = Colors.green;
        label = 'مؤكد';
        break;
      case VerificationStatus.underVerification:
        color = Colors.orange;
        label = 'قيد التحقق';
        break;
      case VerificationStatus.declarative:
        color = Colors.grey;
        label = 'تصريحي';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
