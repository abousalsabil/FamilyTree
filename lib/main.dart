import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/family_repository.dart';
import 'widgets/interactive_tree_widget.dart';
import 'widgets/member_dialogs.dart';
import 'widgets/verifications_and_documents_widget.dart';

void main() {
  runApp(const FamilyTreeApp());
}

class FamilyTreeApp extends StatefulWidget {
  const FamilyTreeApp({super.key});

  @override
  State<FamilyTreeApp> createState() => _FamilyTreeAppState();
}

class _FamilyTreeAppState extends State<FamilyTreeApp> {
  final FamilyRepository repository = FamilyRepository();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: repository,
      builder: (context, _) {
        return MaterialApp(
          title: 'شجرة العائلة',
          debugShowCheckedModeBanner: false,
          locale: const Locale('ar'),
          supportedLocales: const [
            Locale('ar'),
            Locale('fr'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            primarySwatch: Colors.teal,
            fontFamily: 'Cairo',
            useMaterial3: true,
          ),
          home: HomeScreen(repository: repository),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  final FamilyRepository repository;

  const HomeScreen({super.key, required this.repository});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = widget.repository.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/icons/family_circle_icon.png',
              height: 36,
              width: 36,
            ),
            const SizedBox(width: 10),
            const Text('شجرة العائلة'),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'إضافة فرد',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddMemberDialog(repository: widget.repository),
              );
            },
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.name ?? 'زائر'),
              accountEmail: Text(user?.email ?? 'غير مسجل'),
              currentAccountPicture: ClipOval(
                child: Image.asset('assets/icons/family_circle_icon.png'),
              ),
              decoration: const BoxDecoration(color: Colors.teal),
            ),
            ListTile(
              leading: const Icon(Icons.account_tree),
              title: const Text('الشجرة التفاعلية'),
              onTap: () {
                setState(() => _currentIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.verified),
              title: const Text('التحقق والوثائق'),
              onTap: () {
                setState(() => _currentIndex = 1);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _currentIndex == 0
          ? InteractiveTreeWidget(
              repository: widget.repository,
              onMemberTap: (member) {
                showDialog(
                  context: context,
                  builder: (context) => MemberDetailDialog(
                    member: member,
                    repository: widget.repository,
                  ),
                );
              },
            )
          : VerificationsAndDocumentsWidget(repository: widget.repository),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_tree),
            label: 'الشجرة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified),
            label: 'التحقق والوثائق',
          ),
        ],
      ),
    );
  }
}
