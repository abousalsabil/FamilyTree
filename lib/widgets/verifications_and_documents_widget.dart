import 'package:flutter/material.dart';
import '../services/family_repository.dart';
import '../models/verification_and_document.dart';

class VerificationsAndDocumentsWidget extends StatelessWidget {
  final FamilyRepository repository;

  const VerificationsAndDocumentsWidget({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.how_to_vote), text: 'طلبات التحقق Communautaires'),
              Tab(icon: Icon(Icons.description), text: 'الوثائق الرسمية'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildVerificationsTab(context),
                _buildDocumentsTab(context),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildVerificationsTab(BuildContext context) {
    final verifications = repository.verifications;

    if (verifications.isEmpty) {
      return const Center(child: Text('لا توجد طلبات تحقق حالية'));
    }

    return ListView.builder(
      itemCount: verifications.length,
      itemBuilder: (context, index) {
        final item = verifications[index];
        final member = repository.members.where((m) => m.id == item.targetMemberId).firstOrNull;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(member?.fullName ?? 'عضو جديد'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.description),
                const SizedBox(height: 4),
                Text('الموافقات: ${item.approvalsCount} | الرفض: ${item.rejectionsCount}'),
              ],
            ),
            trailing: item.status == VerificationRequestStatus.pending
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () => repository.voteVerification(item.id, true),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => repository.voteVerification(item.id, false),
                      ),
                    ],
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.status == VerificationRequestStatus.approved ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.status == VerificationRequestStatus.approved ? 'مقبول' : 'مرفوض',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildDocumentsTab(BuildContext context) {
    final documents = repository.documents;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDocumentDialog(context),
        icon: const Icon(Icons.upload_file),
        label: const Text('إضافة وثيقة'),
      ),
      body: documents.isEmpty
          ? const Center(child: Text('لا توجد وثائق رسمية مرفوعة'))
          : ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final doc = documents[index];
                final member = repository.members.where((m) => m.id == doc.memberId).firstOrNull;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                    title: Text(doc.title),
                    subtitle: Text('المالك: ${member?.fullName ?? "غير معروف"}'),
                    trailing: Icon(
                      doc.isVerified ? Icons.verified : Icons.hourglass_empty,
                      color: doc.isVerified ? Colors.green : Colors.orange,
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showAddDocumentDialog(BuildContext context) {
    final titleController = TextEditingController();
    String? selectedMemberId = repository.members.firstOrNull?.id;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('رفع وثيقة رسمية جديدة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedMemberId,
              decoration: const InputDecoration(labelText: 'اختر العضو المعني'),
              items: repository.members
                  .map((m) => DropdownMenuItem(
                        value: m.id,
                        child: Text(m.fullName),
                      ))
                  .toList(),
              onChanged: (val) => selectedMemberId = val,
            ),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'عنوان الوثيقة (مثل: شهادة الميلاد)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && selectedMemberId != null) {
                repository.addDocument(
                  OfficialDocument(
                    id: 'd_${DateTime.now().millisecondsSinceEpoch}',
                    memberId: selectedMemberId!,
                    type: DocumentType.birthCertificate,
                    title: titleController.text,
                    fileUrl: 'https://example.com/uploaded.pdf',
                    isVerified: false,
                  ),
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('رفع'),
          )
        ],
      ),
    );
  }
}
