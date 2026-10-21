import 'package:flutter/material.dart';
import '../models/family_member.dart';
import '../services/family_repository.dart';

class MemberDetailDialog extends StatelessWidget {
  final FamilyMember member;
  final FamilyRepository repository;

  const MemberDetailDialog({
    super.key,
    required this.member,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    final father = repository.members.where((m) => m.id == member.fatherId).firstOrNull;
    final mother = repository.members.where((m) => m.id == member.motherId).firstOrNull;
    final spouse = repository.members.where((m) => m.id == member.spouseId).firstOrNull;
    final children = repository.members.where((m) => member.childrenIds.contains(m.id)).toList();

    return AlertDialog(
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: member.gender == Gender.male ? Colors.blue : Colors.pink,
            child: Icon(
              member.gender == Gender.male ? Icons.person : Icons.person_2,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              member.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoRow('الحالة الحيوية:', member.isAlive ? 'على قيد الحياة' : 'متوفى'),
            if (member.birthDate != null) _buildInfoRow('تاريخ الميلاد:', member.birthDate!),
            if (member.birthPlace != null) _buildInfoRow('مكان الميلاد:', member.birthPlace!),
            const Divider(),
            const Text('العلاقات العائلية:', style: TextStyle(fontWeight: FontWeight.bold)),
            if (father != null) _buildInfoRow('الأب:', father.fullName),
            if (mother != null) _buildInfoRow('الأم:', mother.fullName),
            if (spouse != null) _buildInfoRow('الزوج / الزوجة:', spouse.fullName),
            if (children.isNotEmpty)
              _buildInfoRow(
                'الأبناء:',
                children.map((c) => c.firstName).join('، '),
              ),
            if (member.biography != null && member.biography!.isNotEmpty) ...[
              const Divider(),
              const Text('السيرة الذاتية / ملاحظات:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(member.biography!),
            ]
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class AddMemberDialog extends StatefulWidget {
  final FamilyRepository repository;

  const AddMemberDialog({super.key, required this.repository});

  @override
  State<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<AddMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  String _firstName = '';
  String _fatherName = '';
  String _grandFatherName = '';
  String _familyName = '';
  Gender _gender = Gender.male;
  String? _birthDate;
  String? _birthPlace;
  String? _selectedFatherId;

  @override
  Widget build(BuildContext context) {
    final potentialFathers = widget.repository.members.where((m) => m.gender == Gender.male).toList();

    return AlertDialog(
      title: const Text('إضافة فرد جديد للنزب/العائلة'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'الاسم الأول *'),
                validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                onSaved: (v) => _firstName = v!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'اسم الأب *'),
                validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                onSaved: (v) => _fatherName = v!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'اسم الجد *'),
                validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                onSaved: (v) => _grandFatherName = v!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'اللقب / اسم العائلة *'),
                validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                onSaved: (v) => _familyName = v!,
              ),
              DropdownButtonFormField<Gender>(
                value: _gender,
                decoration: const InputDecoration(labelText: 'الجنس'),
                items: const [
                  DropdownMenuItem(value: Gender.male, child: Text('ذكر')),
                  DropdownMenuItem(value: Gender.female, child: Text('أنثى')),
                ],
                onChanged: (val) => setState(() => _gender = val!),
              ),
              DropdownButtonFormField<String>(
                value: _selectedFatherId,
                decoration: const InputDecoration(labelText: 'ربط بالأب (اختياري)'),
                items: [
                  const DropdownMenuItem<String>(value: null, child: Text('بدون تحديد')),
                  ...potentialFathers.map((f) => DropdownMenuItem(
                        value: f.id,
                        child: Text(f.fullName),
                      )),
                ],
                onChanged: (val) => setState(() => _selectedFatherId = val),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'تاريخ الميلاد (مثال: 1995-06-15)'),
                onSaved: (v) => _birthDate = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'مكان الميلاد'),
                onSaved: (v) => _birthPlace = v,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final newMember = FamilyMember(
                id: 'm_${DateTime.now().millisecondsSinceEpoch}',
                firstName: _firstName,
                fatherName: _fatherName,
                grandFatherName: _grandFatherName,
                familyName: _familyName,
                gender: _gender,
                birthDate: _birthDate,
                birthPlace: _birthPlace,
                fatherId: _selectedFatherId,
                status: VerificationStatus.declarative,
              );
              widget.repository.addMember(newMember);
              Navigator.pop(context);
            }
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
