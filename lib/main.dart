import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(PlacementPortalApp(controller: AppController()));
}

enum UserRole { admin, principal, tpOfficer, coordinator, student }

enum OpportunityType { job, internship }

enum PreferredInterest { business, job, higherStudies }

class AppUser {
  const AppUser({
    required this.name,
    required this.email,
    required this.role,
  });

  final String name;
  final String email;
  final UserRole role;
}

class Department {
  const Department({required this.id, required this.name});

  final String id;
  final String name;

  Department copyWith({String? id, String? name}) {
    return Department(id: id ?? this.id, name: name ?? this.name);
  }
}

class AcademicClass {
  const AcademicClass({
    required this.id,
    required this.departmentId,
    required this.name,
    required this.batch,
  });

  final String id;
  final String departmentId;
  final String name;
  final String batch;

  AcademicClass copyWith({
    String? id,
    String? departmentId,
    String? name,
    String? batch,
  }) {
    return AcademicClass(
      id: id ?? this.id,
      departmentId: departmentId ?? this.departmentId,
      name: name ?? this.name,
      batch: batch ?? this.batch,
    );
  }
}

class StudentRecord {
  const StudentRecord({
    required this.id,
    required this.classId,
    required this.rollNo,
    required this.name,
    required this.gender,
    required this.personalMobile,
    required this.parentsMobile,
    required this.personalEmail,
    required this.linkedinProfile,
    required this.sscPercentage,
    required this.hscPercentage,
    required this.diplomaPercentage,
    required this.semesters,
    required this.courses,
    required this.internships,
    required this.trainings,
    required this.skillset,
    required this.preferredInterest,
    required this.photoUrl,
    required this.appliedOpportunityIds,
  });

  final String id;
  final String classId;
  final String rollNo;
  final String name;
  final String gender;
  final String personalMobile;
  final String parentsMobile;
  final String personalEmail;
  final String linkedinProfile;
  final double sscPercentage;
  final double hscPercentage;
  final double diplomaPercentage;
  final List<double> semesters;
  final String courses;
  final String internships;
  final String trainings;
  final String skillset;
  final PreferredInterest preferredInterest;
  final String photoUrl;
  final List<String> appliedOpportunityIds;

  StudentRecord copyWith({
    String? id,
    String? classId,
    String? rollNo,
    String? name,
    String? gender,
    String? personalMobile,
    String? parentsMobile,
    String? personalEmail,
    String? linkedinProfile,
    double? sscPercentage,
    double? hscPercentage,
    double? diplomaPercentage,
    List<double>? semesters,
    String? courses,
    String? internships,
    String? trainings,
    String? skillset,
    PreferredInterest? preferredInterest,
    String? photoUrl,
    List<String>? appliedOpportunityIds,
  }) {
    return StudentRecord(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      rollNo: rollNo ?? this.rollNo,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      personalMobile: personalMobile ?? this.personalMobile,
      parentsMobile: parentsMobile ?? this.parentsMobile,
      personalEmail: personalEmail ?? this.personalEmail,
      linkedinProfile: linkedinProfile ?? this.linkedinProfile,
      sscPercentage: sscPercentage ?? this.sscPercentage,
      hscPercentage: hscPercentage ?? this.hscPercentage,
      diplomaPercentage: diplomaPercentage ?? this.diplomaPercentage,
      semesters: semesters ?? this.semesters,
      courses: courses ?? this.courses,
      internships: internships ?? this.internships,
      trainings: trainings ?? this.trainings,
      skillset: skillset ?? this.skillset,
      preferredInterest: preferredInterest ?? this.preferredInterest,
      photoUrl: photoUrl ?? this.photoUrl,
      appliedOpportunityIds: appliedOpportunityIds ?? this.appliedOpportunityIds,
    );
  }
}

class Opportunity {
  const Opportunity({
    required this.id,
    required this.title,
    required this.company,
    required this.type,
    required this.batch,
    required this.description,
    required this.packageLpa,
    required this.postedBy,
    required this.applicantIds,
  });

  final String id;
  final String title;
  final String company;
  final OpportunityType type;
  final String batch;
  final String description;
  final double packageLpa;
  final UserRole postedBy;
  final List<String> applicantIds;

  Opportunity copyWith({
    String? id,
    String? title,
    String? company,
    OpportunityType? type,
    String? batch,
    String? description,
    double? packageLpa,
    UserRole? postedBy,
    List<String>? applicantIds,
  }) {
    return Opportunity(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      type: type ?? this.type,
      batch: batch ?? this.batch,
      description: description ?? this.description,
      packageLpa: packageLpa ?? this.packageLpa,
      postedBy: postedBy ?? this.postedBy,
      applicantIds: applicantIds ?? this.applicantIds,
    );
  }
}

class AppController extends ChangeNotifier {
  AppController() {
    _seedData();
  }

  final List<Department> departments = [];
  final List<AcademicClass> classes = [];
  final List<StudentRecord> students = [];
  final List<Opportunity> opportunities = [];

  AppUser? currentUser;
  ThemeMode themeMode = ThemeMode.light;
  String dashboardSearch = '';

  bool get isDarkMode => themeMode == ThemeMode.dark;

  bool get canManageAcademics => currentUser != null && currentUser!.role != UserRole.student;

  bool get canManageOpportunities => currentUser != null && {
        UserRole.admin,
        UserRole.tpOfficer,
        UserRole.coordinator,
      }.contains(currentUser!.role);

  void toggleTheme() {
    themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void login({required String email, required String name, required UserRole role}) {
    if (role == UserRole.student) {
      _ensureStudentProfile(name: name, email: email);
    }
    currentUser = AppUser(name: name, email: email, role: role);
    notifyListeners();
  }

  void logout() {
    currentUser = null;
    dashboardSearch = '';
    notifyListeners();
  }

  void updateDashboardSearch(String value) {
    dashboardSearch = value;
    notifyListeners();
  }

  List<StudentRecord> get searchedStudents {
    final query = dashboardSearch.trim().toLowerCase();
    if (query.isEmpty) {
      return students.take(5).toList();
    }
    return students.where((student) {
      return student.name.toLowerCase().contains(query) ||
          student.rollNo.toLowerCase().contains(query) ||
          student.personalEmail.toLowerCase().contains(query) ||
          student.skillset.toLowerCase().contains(query);
    }).toList();
  }

  List<String> get batches {
    final values = classes.map((item) => item.batch).toSet().toList()..sort();
    return values;
  }

  Department departmentForClass(String classId) {
    final currentClass = classes.firstWhere((item) => item.id == classId);
    return departments.firstWhere((item) => item.id == currentClass.departmentId);
  }

  AcademicClass? classById(String id) {
    for (final academicClass in classes) {
      if (academicClass.id == id) {
        return academicClass;
      }
    }
    return null;
  }

  StudentRecord? currentStudentProfile() {
    if (currentUser == null || currentUser!.role != UserRole.student) {
      return null;
    }
    for (final student in students) {
      if (student.personalEmail.toLowerCase() == currentUser!.email.toLowerCase()) {
        return student;
      }
    }
    return students.isNotEmpty ? students.first : null;
  }

  void upsertDepartment(Department department) {
    final index = departments.indexWhere((item) => item.id == department.id);
    if (index == -1) {
      departments.add(department);
    } else {
      departments[index] = department;
    }
    notifyListeners();
  }

  void deleteDepartment(String departmentId) {
    final classIds = classes.where((item) => item.departmentId == departmentId).map((item) => item.id).toSet();
    classes.removeWhere((item) => item.departmentId == departmentId);
    students.removeWhere((item) => classIds.contains(item.classId));
    departments.removeWhere((item) => item.id == departmentId);
    notifyListeners();
  }

  void upsertClass(AcademicClass academicClass) {
    final index = classes.indexWhere((item) => item.id == academicClass.id);
    if (index == -1) {
      classes.add(academicClass);
    } else {
      classes[index] = academicClass;
    }
    notifyListeners();
  }

  void deleteClass(String classId) {
    classes.removeWhere((item) => item.id == classId);
    students.removeWhere((item) => item.classId == classId);
    notifyListeners();
  }

  void upsertStudent(StudentRecord student) {
    final index = students.indexWhere((item) => item.id == student.id);
    if (index == -1) {
      students.add(student);
    } else {
      students[index] = student;
    }
    notifyListeners();
  }

  void deleteStudent(String studentId) {
    students.removeWhere((item) => item.id == studentId);
    for (var index = 0; index < opportunities.length; index++) {
      final current = opportunities[index];
      opportunities[index] = current.copyWith(
        applicantIds: current.applicantIds.where((id) => id != studentId).toList(),
      );
    }
    notifyListeners();
  }

  int importStudentsFromCsv({required String classId, required String csvText}) {
    final lines = csvText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (lines.length < 2) {
      return 0;
    }

    var imported = 0;
    for (final row in lines.skip(1)) {
      final values = row.split(',');
      if (values.length < 20) {
        continue;
      }
      upsertStudent(
        StudentRecord(
          id: 'student-${students.length + imported + 1}',
          classId: classId,
          rollNo: values[0].trim(),
          name: values[1].trim(),
          gender: values[2].trim(),
          personalMobile: values[3].trim(),
          parentsMobile: values[4].trim(),
          personalEmail: values[5].trim(),
          linkedinProfile: values[6].trim(),
          sscPercentage: _toDouble(values[7]),
          hscPercentage: _toDouble(values[8]),
          diplomaPercentage: _toDouble(values[9]),
          semesters: values.sublist(10, 18).map(_toDouble).toList(),
          courses: values[18].trim(),
          internships: values[19].trim(),
          trainings: values.length > 20 ? values[20].trim() : '',
          skillset: values.length > 21 ? values[21].trim() : '',
          preferredInterest: values.length > 22
              ? _preferredInterestFromLabel(values[22].trim())
              : PreferredInterest.job,
          photoUrl: values.length > 23 ? values[23].trim() : '',
          appliedOpportunityIds: const [],
        ),
      );
      imported++;
    }
    notifyListeners();
    return imported;
  }

  void upsertOpportunity(Opportunity opportunity) {
    final index = opportunities.indexWhere((item) => item.id == opportunity.id);
    if (index == -1) {
      opportunities.add(opportunity);
    } else {
      opportunities[index] = opportunity;
    }
    notifyListeners();
  }

  void deleteOpportunity(String opportunityId) {
    opportunities.removeWhere((item) => item.id == opportunityId);
    for (var index = 0; index < students.length; index++) {
      final student = students[index];
      students[index] = student.copyWith(
        appliedOpportunityIds: student.appliedOpportunityIds.where((id) => id != opportunityId).toList(),
      );
    }
    notifyListeners();
  }

  void applyToOpportunity({required String studentId, required String opportunityId}) {
    final studentIndex = students.indexWhere((item) => item.id == studentId);
    final opportunityIndex = opportunities.indexWhere((item) => item.id == opportunityId);
    if (studentIndex == -1 || opportunityIndex == -1) {
      return;
    }
    final student = students[studentIndex];
    final opportunity = opportunities[opportunityIndex];
    if (!student.appliedOpportunityIds.contains(opportunityId)) {
      students[studentIndex] = student.copyWith(
        appliedOpportunityIds: [...student.appliedOpportunityIds, opportunityId],
      );
      opportunities[opportunityIndex] = opportunity.copyWith(
        applicantIds: [...opportunity.applicantIds, studentId],
      );
      notifyListeners();
    }
  }

  String exportBatchSummary(String batch, {required bool asPdf}) {
    final batchClasses = classes.where((item) => item.batch == batch).toList();
    final batchClassIds = batchClasses.map((item) => item.id).toSet();
    final batchStudents = students.where((item) => batchClassIds.contains(item.classId)).toList();
    final batchOpportunities = opportunities.where((item) => item.batch == batch).toList();
    final topPackage = batchOpportunities.isEmpty
        ? 0.0
        : batchOpportunities.map((item) => item.packageLpa).reduce((a, b) => a > b ? a : b);
    final header = asPdf ? 'PDF Export Preview' : 'Excel Export Preview';
    final buffer = StringBuffer()
      ..writeln(header)
      ..writeln('Batch: $batch')
      ..writeln('Departments: ${batchClasses.map((item) => departments.firstWhere((dept) => dept.id == item.departmentId).name).toSet().join(', ')}')
      ..writeln('Classes: ${batchClasses.map((item) => item.name).join(', ')}')
      ..writeln('Students: ${batchStudents.length}')
      ..writeln('Openings: ${batchOpportunities.length}')
      ..writeln('Highest package: ${topPackage.toStringAsFixed(1)} LPA')
      ..writeln('--- Student Snapshot ---');
    for (final student in batchStudents) {
      buffer.writeln('${student.rollNo} | ${student.name} | ${student.personalEmail} | ${student.skillset}');
    }
    return buffer.toString();
  }

  void _ensureStudentProfile({required String name, required String email}) {
    final exists = students.any((student) => student.personalEmail.toLowerCase() == email.toLowerCase());
    if (exists || classes.isEmpty) {
      return;
    }
    students.add(
      StudentRecord(
        id: 'student-${students.length + 1}',
        classId: classes.first.id,
        rollNo: 'NEW${students.length + 1}',
        name: name,
        gender: 'Not specified',
        personalMobile: '',
        parentsMobile: '',
        personalEmail: email,
        linkedinProfile: '',
        sscPercentage: 0,
        hscPercentage: 0,
        diplomaPercentage: 0,
        semesters: const [0, 0, 0, 0, 0, 0, 0, 0],
        courses: '',
        internships: '',
        trainings: '',
        skillset: '',
        preferredInterest: PreferredInterest.job,
        photoUrl: '',
        appliedOpportunityIds: const [],
      ),
    );
  }

  void _seedData() {
    const seedDepartments = [
      'Computer',
      'CSE(AIML)',
      'CSE(DS)',
      'ECS',
      'ECE',
      'CE',
      'ME',
    ];
    for (var index = 0; index < seedDepartments.length; index++) {
      departments.add(Department(id: 'dept-$index', name: seedDepartments[index]));
    }

    classes.addAll([
      const AcademicClass(id: 'class-1', departmentId: 'dept-0', name: 'TY Computer A', batch: '2022-2026'),
      const AcademicClass(id: 'class-2', departmentId: 'dept-1', name: 'TY AIML A', batch: '2022-2026'),
      const AcademicClass(id: 'class-3', departmentId: 'dept-3', name: 'TY ECS A', batch: '2021-2025'),
    ]);

    students.addAll([
      StudentRecord(
        id: 'student-1',
        classId: 'class-1',
        rollNo: 'C101',
        name: 'Aarav Kulkarni',
        gender: 'Male',
        personalMobile: '9876543210',
        parentsMobile: '9123456780',
        personalEmail: 'aarav@example.com',
        linkedinProfile: 'https://linkedin.com/in/aarav',
        sscPercentage: 89.2,
        hscPercentage: 84.3,
        diplomaPercentage: 0,
        semesters: const [8.2, 8.4, 8.7, 8.8, 9.0, 9.1, 9.3, 9.4],
        courses: 'Data Structures, Flutter, Cloud Basics',
        internships: 'Android Developer Intern - TechNova',
        trainings: 'Aptitude Bootcamp, AWS Academy',
        skillset: 'Flutter, Firebase, REST APIs',
        preferredInterest: PreferredInterest.job,
        photoUrl: '',
        appliedOpportunityIds: const ['opp-1'],
      ),
      StudentRecord(
        id: 'student-2',
        classId: 'class-2',
        rollNo: 'A201',
        name: 'Siya Patil',
        gender: 'Female',
        personalMobile: '9988776655',
        parentsMobile: '9012345678',
        personalEmail: 'siya@example.com',
        linkedinProfile: 'https://linkedin.com/in/siya',
        sscPercentage: 91.0,
        hscPercentage: 88.0,
        diplomaPercentage: 0,
        semesters: const [8.8, 8.9, 9.0, 9.1, 9.2, 9.3, 9.4, 9.5],
        courses: 'Machine Learning, Power BI',
        internships: 'Data Analyst Intern - Insight Labs',
        trainings: 'Python for AI',
        skillset: 'Python, ML, SQL, Power BI',
        preferredInterest: PreferredInterest.higherStudies,
        photoUrl: '',
        appliedOpportunityIds: const [],
      ),
    ]);

    opportunities.addAll([
      const Opportunity(
        id: 'opp-1',
        title: 'Graduate Software Engineer',
        company: 'Infosys',
        type: OpportunityType.job,
        batch: '2022-2026',
        description: 'Campus drive for software engineering roles.',
        packageLpa: 7.5,
        postedBy: UserRole.tpOfficer,
        applicantIds: ['student-1'],
      ),
      const Opportunity(
        id: 'opp-2',
        title: 'AI Research Internship',
        company: 'OpenVision Labs',
        type: OpportunityType.internship,
        batch: '2022-2026',
        description: 'Six month internship for AIML students.',
        packageLpa: 2.0,
        postedBy: UserRole.coordinator,
        applicantIds: [],
      ),
      const Opportunity(
        id: 'opp-3',
        title: 'Core Electronics Internship',
        company: 'Sky Circuits',
        type: OpportunityType.internship,
        batch: '2021-2025',
        description: 'Hands-on internship for ECS and ECE students.',
        packageLpa: 1.5,
        postedBy: UserRole.tpOfficer,
        applicantIds: [],
      ),
    ]);
  }
}

class PlacementPortalApp extends StatelessWidget {
  const PlacementPortalApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'TNP Cell Portal',
          themeMode: controller.themeMode,
          theme: _theme(Brightness.light),
          darkTheme: _theme(Brightness.dark),
          home: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: controller.currentUser == null
                ? AuthScreen(controller: controller)
                : HomeScreen(controller: controller),
          ),
        );
      },
    );
  }

  ThemeData _theme(Brightness brightness) {
    final seed = brightness == Brightness.dark ? const Color(0xFF7C4DFF) : const Color(0xFF0F6CBD);
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    final base = ThemeData(
      brightness: brightness,
      colorScheme: scheme,
      useMaterial3: true,
      cardTheme: CardTheme(
        elevation: brightness == Brightness.dark ? 0 : 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
        filled: true,
      ),
    );

    final textTheme = GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
      headlineMedium: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
      headlineSmall: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
      titleLarge: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
      titleMedium: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
    );

    return base.copyWith(textTheme: textTheme);
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'TP Officer');
  final _emailController = TextEditingController(text: 'officer@appTNP.in');
  final _passwordController = TextEditingController(text: 'password');
  var _isLogin = true;
  var _role = UserRole.tpOfficer;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.surface,
              theme.colorScheme.secondaryContainer,
            ],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 820;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Flex(
                        direction: wide ? Axis.horizontal : Axis.vertical,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _AuthHeroPanel(isLogin: _isLogin),
                          ),
                          const SizedBox(width: 24, height: 24),
                          Expanded(
                            child: Form(
                              key: _formKey,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: Column(
                                  key: ValueKey(_isLogin),
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isLogin ? 'TNP Cell Portal' : 'Create your portal account',
                                      style: theme.textTheme.headlineSmall,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _isLogin
                                          ? 'Secure sign-in for administrators, coordinators, principals and students.'
                                          : 'Register with role based access for Training and Placement workflows.',
                                    ),
                                    const SizedBox(height: 24),
                                    if (!_isLogin) ...[
                                      TextFormField(
                                        controller: _nameController,
                                        decoration: const InputDecoration(labelText: 'Full name'),
                                        validator: (value) => value == null || value.trim().isEmpty ? 'Enter a name' : null,
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                    TextFormField(
                                      controller: _emailController,
                                      decoration: const InputDecoration(labelText: 'Email'),
                                      validator: (value) => value == null || !value.contains('@') ? 'Enter a valid email' : null,
                                    ),
                                    const SizedBox(height: 16),
                                    DropdownButtonFormField<UserRole>(
                                      value: _role,
                                      decoration: const InputDecoration(labelText: 'Role'),
                                      items: UserRole.values
                                          .map(
                                            (role) => DropdownMenuItem(
                                              value: role,
                                              child: Text(roleLabel(role)),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) => setState(() => _role = value ?? UserRole.student),
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: true,
                                      decoration: const InputDecoration(labelText: 'Password'),
                                      validator: (value) => value == null || value.length < 4 ? 'Use at least 4 characters' : null,
                                    ),
                                    const SizedBox(height: 24),
                                    FilledButton.icon(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          final displayName = _isLogin
                                              ? (_role == UserRole.student ? 'Student User' : roleLabel(_role))
                                              : _nameController.text.trim();
                                          widget.controller.login(
                                            email: _emailController.text.trim(),
                                            name: displayName,
                                            role: _role,
                                          );
                                        }
                                      },
                                      icon: Icon(_isLogin ? Icons.login_rounded : Icons.app_registration_rounded),
                                      label: Text(_isLogin ? 'Login' : 'Register'),
                                    ),
                                    const SizedBox(height: 12),
                                    TextButton(
                                      onPressed: () => setState(() => _isLogin = !_isLogin),
                                      child: Text(_isLogin ? 'Create account' : 'Back to login'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthHeroPanel extends StatelessWidget {
  const _AuthHeroPanel({required this.isLogin});

  final bool isLogin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: theme.colorScheme.onPrimary.withOpacity(0.14),
            child: const FaIcon(FontAwesomeIcons.userGraduate, color: Colors.white),
          ),
          const SizedBox(height: 24),
          Text(
            isLogin ? 'Placement data, jobs and student outcomes in one portal.' : 'Beautiful role-based workflows for every stakeholder.',
            style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'Manage departments, classes, students, opportunities, applications, exports and analytics with a polished Flutter experience.',
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _FeatureChip(icon: FontAwesomeIcons.building, label: 'Departments'),
              _FeatureChip(icon: FontAwesomeIcons.usersViewfinder, label: 'Student Search'),
              _FeatureChip(icon: FontAwesomeIcons.briefcase, label: 'Jobs & Internships'),
              _FeatureChip(icon: FontAwesomeIcons.fileExport, label: 'Excel / PDF'),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: FaIcon(icon, size: 14, color: Colors.white),
      label: Text(label),
      labelStyle: const TextStyle(color: Colors.white),
      backgroundColor: Colors.white.withOpacity(0.14),
      side: BorderSide.none,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardPage(controller: widget.controller),
      DepartmentsPage(controller: widget.controller),
      ClassesPage(controller: widget.controller),
      StudentsPage(controller: widget.controller),
      OpportunitiesPage(controller: widget.controller),
      ProfilePage(controller: widget.controller),
    ];
    final destinations = const [
      NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
      NavigationDestination(icon: Icon(Icons.account_tree_outlined), selectedIcon: Icon(Icons.account_tree_rounded), label: 'Departments'),
      NavigationDestination(icon: Icon(Icons.class_outlined), selectedIcon: Icon(Icons.class_rounded), label: 'Classes'),
      NavigationDestination(icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups_rounded), label: 'Students'),
      NavigationDestination(icon: Icon(Icons.work_outline_rounded), selectedIcon: Icon(Icons.work_rounded), label: 'Opportunities'),
      NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('TNP Cell Portal'),
            Text(
              '${widget.controller.currentUser!.name} • ${roleLabel(widget.controller.currentUser!.role)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: widget.controller.toggleTheme,
            icon: Icon(widget.controller.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: widget.controller.logout,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: screens[_index],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        destinations: destinations,
        onDestinationSelected: (value) => setState(() => _index = value),
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? _selectedBatch;

  @override
  void initState() {
    super.initState();
    _selectedBatch = widget.controller.batches.isNotEmpty ? widget.controller.batches.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    if (controller.batches.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('Add classes with batches to unlock analytics and exports.'),
            ),
          ),
        ],
      );
    }
    final batch = _selectedBatch ?? controller.batches.first;
    final batchClasses = controller.classes.where((item) => item.batch == batch).toList();
    final batchClassIds = batchClasses.map((item) => item.id).toSet();
    final batchStudents = controller.students.where((item) => batchClassIds.contains(item.classId)).toList();
    final batchOpportunities = controller.opportunities.where((item) => item.batch == batch).toList();
    final topPackage = batchOpportunities.isEmpty
        ? 0.0
        : batchOpportunities.map((item) => item.packageLpa).reduce((a, b) => a > b ? a : b);
    final recruiters = batchOpportunities.map((item) => item.company).toSet().toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 240,
              child: DropdownButtonFormField<String>(
                value: batch,
                decoration: const InputDecoration(labelText: 'Batch focus'),
                items: controller.batches
                    .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedBatch = value),
              ),
            ),
            FilledButton.icon(
              onPressed: () => _showPreviewDialog(context, 'Excel Export', controller.exportBatchSummary(batch, asPdf: false)),
              icon: const Icon(Icons.table_view_rounded),
              label: const Text('Export Excel'),
            ),
            OutlinedButton.icon(
              onPressed: () => _showPreviewDialog(context, 'PDF Export', controller.exportBatchSummary(batch, asPdf: true)),
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: const Text('Export PDF'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _StatCard(title: 'Departments', value: controller.departments.length.toString(), icon: FontAwesomeIcons.buildingColumns),
            _StatCard(title: 'Classes', value: batchClasses.length.toString(), icon: FontAwesomeIcons.schoolCircleCheck),
            _StatCard(title: 'Students', value: batchStudents.length.toString(), icon: FontAwesomeIcons.userGraduate),
            _StatCard(title: 'Highest Package', value: '${topPackage.toStringAsFixed(1)} LPA', icon: FontAwesomeIcons.indianRupeeSign),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Highlights', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _DashboardChip(label: '${batchOpportunities.where((item) => item.type == OpportunityType.job).length} jobs live'),
                    _DashboardChip(label: '${batchOpportunities.where((item) => item.type == OpportunityType.internship).length} internships live'),
                    _DashboardChip(label: '${batchStudents.where((item) => item.preferredInterest == PreferredInterest.higherStudies).length} higher studies aspirants'),
                    for (final recruiter in recruiters) _DashboardChip(label: recruiter),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Search students from dashboard', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                TextField(
                  onChanged: controller.updateDashboardSearch,
                  decoration: const InputDecoration(
                    labelText: 'Search by name, roll number, email or skill',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                ...controller.searchedStudents.map(
                  (student) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(child: Text(initials(student.name))),
                    title: Text(student.name),
                    subtitle: Text('${student.rollNo} • ${controller.classById(student.classId)?.batch ?? ''} • ${student.skillset}'),
                    trailing: Text(student.preferredInterest.name),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value, required this.icon});

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 230,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(icon, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(value, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(title),
        ],
      ),
    );
  }
}

class _DashboardChip extends StatelessWidget {
  const _DashboardChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label));
  }
}

class DepartmentsPage extends StatelessWidget {
  const DepartmentsPage({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(child: Text('Departments', style: Theme.of(context).textTheme.headlineSmall)),
              if (controller.canManageAcademics)
                FilledButton.icon(
                  onPressed: () async {
                    final department = await showDepartmentDialog(context);
                    if (department != null) {
                      controller.upsertDepartment(
                        Department(id: 'dept-${controller.departments.length + 1}', name: department),
                      );
                    }
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add department'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ...controller.departments.map(
            (department) {
              final classesCount = controller.classes.where((item) => item.departmentId == department.id).length;
              return Card(
                child: ListTile(
                  leading: const FaIcon(FontAwesomeIcons.building),
                  title: Text(department.name),
                  subtitle: Text('$classesCount classes linked'),
                  trailing: controller.canManageAcademics
                      ? Wrap(
                          spacing: 8,
                          children: [
                            IconButton(
                              onPressed: () async {
                                final renamed = await showDepartmentDialog(context, initialValue: department.name);
                                if (renamed != null) {
                                  controller.upsertDepartment(department.copyWith(name: renamed));
                                }
                              },
                              icon: const Icon(Icons.edit_rounded),
                            ),
                            IconButton(
                              onPressed: () => controller.deleteDepartment(department.id),
                              icon: const Icon(Icons.delete_outline_rounded),
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ClassesPage extends StatelessWidget {
  const ClassesPage({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(child: Text('Department Classes', style: Theme.of(context).textTheme.headlineSmall)),
              if (controller.canManageAcademics)
                FilledButton.icon(
                  onPressed: () async {
                    final created = await showClassDialog(context, controller.departments);
                    if (created != null) {
                      controller.upsertClass(created.copyWith(id: 'class-${controller.classes.length + 1}'));
                    }
                  },
                  icon: const Icon(Icons.add_home_work_rounded),
                  label: const Text('Add class'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ...controller.classes.map(
            (academicClass) {
              final department = controller.departments.firstWhere((item) => item.id == academicClass.departmentId);
              final totalStudents = controller.students.where((item) => item.classId == academicClass.id).length;
              return Card(
                child: ListTile(
                  leading: const FaIcon(FontAwesomeIcons.school),
                  title: Text(academicClass.name),
                  subtitle: Text('${department.name} • Batch ${academicClass.batch} • $totalStudents students'),
                  trailing: controller.canManageAcademics
                      ? Wrap(
                          spacing: 8,
                          children: [
                            IconButton(
                              onPressed: () async {
                                final updated = await showClassDialog(context, controller.departments, initialValue: academicClass);
                                if (updated != null) {
                                  controller.upsertClass(updated.copyWith(id: academicClass.id));
                                }
                              },
                              icon: const Icon(Icons.edit_rounded),
                            ),
                            IconButton(
                              onPressed: () => controller.deleteClass(academicClass.id),
                              icon: const Icon(Icons.delete_outline_rounded),
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  String? _classFilter;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final visibleStudents = controller.students.where((student) {
      final matchesClass = _classFilter == null || student.classId == _classFilter;
      final matchesQuery = _query.isEmpty ||
          student.name.toLowerCase().contains(_query) ||
          student.rollNo.toLowerCase().contains(_query) ||
          student.personalEmail.toLowerCase().contains(_query);
      return matchesClass && matchesQuery;
    }).toList();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(child: Text('Students', style: Theme.of(context).textTheme.headlineSmall)),
              if (controller.canManageAcademics) ...[
                FilledButton.icon(
                  onPressed: controller.classes.isEmpty
                      ? null
                      : () async {
                          final student = await showStudentDialog(context, controller.classes);
                          if (student != null) {
                            controller.upsertStudent(student.copyWith(id: 'student-${controller.students.length + 1}'));
                          }
                        },
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: const Text('Add student'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: controller.classes.isEmpty ? null : () => _importCsv(context, controller),
                  icon: const Icon(Icons.upload_file_rounded),
                  label: const Text('Import CSV'),
                ),
              ],
            ],
          ),
          if (controller.canManageAcademics && controller.classes.isEmpty) ...[
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Create a class first before adding or importing students.'),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
                  onPressed: () async {
                    final student = await showStudentDialog(context, controller.classes);
                    if (student != null) {
                      controller.upsertStudent(student.copyWith(id: 'student-${controller.students.length + 1}'));
                    }
                  },
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: const Text('Add student'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _importCsv(context, controller),
                  icon: const Icon(Icons.upload_file_rounded),
                  label: const Text('Import CSV'),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: 280,
                child: DropdownButtonFormField<String?>(
                  value: _classFilter,
                  decoration: const InputDecoration(labelText: 'Filter by class'),
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('All classes')),
                    ...controller.classes.map((item) => DropdownMenuItem<String?>(value: item.id, child: Text('${item.name} (${item.batch})'))),
                  ],
                  onChanged: (value) => setState(() => _classFilter = value),
                ),
              ),
              SizedBox(
                width: 360,
                child: TextField(
                  onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
                  decoration: const InputDecoration(
                    labelText: 'Search students',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _showPreviewDialog(context, 'CSV Sample Template', studentCsvTemplate),
                icon: const Icon(Icons.description_outlined),
                label: const Text('Sample template'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...visibleStudents.map(
            (student) {
              final currentClass = controller.classById(student.classId);
              final department = currentClass == null ? null : controller.departmentForClass(currentClass.id);
              return Card(
                child: ExpansionTile(
                  leading: CircleAvatar(child: Text(initials(student.name))),
                  title: Text(student.name),
                  subtitle: Text('${student.rollNo} • ${currentClass?.name ?? 'Unknown class'} • ${student.personalEmail}'),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _InfoPill(label: 'Department', value: department?.name ?? '-'),
                          _InfoPill(label: 'Batch', value: currentClass?.batch ?? '-'),
                          _InfoPill(label: 'Skills', value: student.skillset),
                          _InfoPill(label: 'Interest', value: preferredInterestLabel(student.preferredInterest)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Courses: ${student.courses}'),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Internships: ${student.internships}'),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Trainings: ${student.trainings}'),
                    ),
                    if (controller.canManageAcademics)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () async {
                              final updated = await showStudentDialog(context, controller.classes, initialValue: student);
                              if (updated != null) {
                                controller.upsertStudent(updated.copyWith(id: student.id));
                              }
                            },
                            icon: const Icon(Icons.edit_rounded),
                            label: const Text('Edit'),
                          ),
                          TextButton.icon(
                            onPressed: () => controller.deleteStudent(student.id),
                            icon: const Icon(Icons.delete_outline_rounded),
                            label: const Text('Delete'),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _importCsv(BuildContext context, AppController controller) async {
    final result = await showCsvImportDialog(context, controller.classes);
    if (result == null) {
      return;
    }
    final imported = controller.importStudentsFromCsv(classId: result.classId, csvText: result.csvText);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$imported students imported')));
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text('$label: $value'),
    );
  }
}

class OpportunitiesPage extends StatefulWidget {
  const OpportunitiesPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<OpportunitiesPage> createState() => _OpportunitiesPageState();
}

class _OpportunitiesPageState extends State<OpportunitiesPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final student = controller.currentStudentProfile();
    final visibleOpportunities = controller.opportunities.where((opportunity) {
      if (_query.isEmpty) {
        return true;
      }
      return opportunity.title.toLowerCase().contains(_query) ||
          opportunity.company.toLowerCase().contains(_query) ||
          opportunity.batch.toLowerCase().contains(_query) ||
          opportunity.description.toLowerCase().contains(_query);
    }).toList();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(child: Text('Jobs & Internships', style: Theme.of(context).textTheme.headlineSmall)),
              if (controller.canManageOpportunities)
                FilledButton.icon(
                  onPressed: controller.batches.isEmpty
                      ? null
                      : () async {
                          final created = await showOpportunityDialog(context, controller.batches);
                          if (created != null) {
                            controller.upsertOpportunity(
                              created.copyWith(
                                id: 'opp-${controller.opportunities.length + 1}',
                                postedBy: controller.currentUser!.role,
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.add_business_rounded),
                  label: const Text('Post opening'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 360,
            child: TextField(
              onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
              decoration: const InputDecoration(
                labelText: 'Search jobs or internships',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...visibleOpportunities.map(
            (opportunity) {
              final applied = student?.appliedOpportunityIds.contains(opportunity.id) ?? false;
              return Card(
                child: ListTile(
                  leading: FaIcon(opportunity.type == OpportunityType.job ? FontAwesomeIcons.briefcase : FontAwesomeIcons.userTie),
                  title: Text('${opportunity.title} • ${opportunity.company}'),
                  subtitle: Text('Batch ${opportunity.batch} • ${opportunity.packageLpa.toStringAsFixed(1)} LPA • ${opportunity.description}'),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      if (controller.currentUser?.role == UserRole.student && student != null)
                        FilledButton(
                          onPressed: applied
                              ? null
                              : () => controller.applyToOpportunity(studentId: student.id, opportunityId: opportunity.id),
                          child: Text(applied ? 'Applied' : 'Apply'),
                        ),
                      if (controller.canManageOpportunities) ...[
                        IconButton(
                          onPressed: () async {
                            final updated = await showOpportunityDialog(context, controller.batches, initialValue: opportunity);
                            if (updated != null) {
                              controller.upsertOpportunity(updated.copyWith(id: opportunity.id, postedBy: opportunity.postedBy));
                            }
                          },
                          icon: const Icon(Icons.edit_rounded),
                        ),
                        IconButton(
                          onPressed: () => controller.deleteOpportunity(opportunity.id),
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final student = controller.currentStudentProfile();
    if (controller.currentUser?.role == UserRole.student && student != null) {
      final appliedOpportunities = controller.opportunities.where((item) => student.appliedOpportunityIds.contains(item.id)).toList();
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(radius: 28, child: Text(initials(student.name))),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(student.name, style: Theme.of(context).textTheme.headlineSmall),
                            Text(student.personalEmail),
                            Text(student.skillset),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _InfoPill(label: 'Roll No', value: student.rollNo),
                      _InfoPill(label: 'Gender', value: student.gender),
                      _InfoPill(label: 'Interest', value: preferredInterestLabel(student.preferredInterest)),
                      _InfoPill(label: 'LinkedIn', value: student.linkedinProfile),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Application history', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  ...appliedOpportunities.map(
                    (opportunity) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.check_circle_rounded),
                      title: Text(opportunity.title),
                      subtitle: Text('${opportunity.company} • ${opportunity.type.name} • ${opportunity.batch}'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Role dashboard', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                Text('Current role: ${roleLabel(controller.currentUser!.role)}'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: const [
                    _DashboardChip(label: 'Manage batches and departments'),
                    _DashboardChip(label: 'Track placements and internships'),
                    _DashboardChip(label: 'Review student profiles and exports'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Future<String?> showDepartmentDialog(BuildContext context, {String? initialValue}) async {
  final controller = TextEditingController(text: initialValue ?? '');
  final formKey = GlobalKey<FormState>();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(initialValue == null ? 'Add Department' : 'Edit Department'),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Department name'),
          validator: (value) => value == null || value.trim().isEmpty ? 'Enter a department name' : null,
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.pop(context, controller.text.trim());
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

Future<AcademicClass?> showClassDialog(
  BuildContext context,
  List<Department> departments, {
  AcademicClass? initialValue,
}) async {
  final nameController = TextEditingController(text: initialValue?.name ?? '');
  final batchController = TextEditingController(text: initialValue?.batch ?? '2022-2026');
  final formKey = GlobalKey<FormState>();
  var selectedDepartmentId = initialValue?.departmentId ?? (departments.isNotEmpty ? departments.first.id : '');

  return showDialog<AcademicClass>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(initialValue == null ? 'Add Class' : 'Edit Class'),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedDepartmentId,
                  decoration: const InputDecoration(labelText: 'Department'),
                  items: departments
                      .map((department) => DropdownMenuItem(value: department.id, child: Text(department.name)))
                      .toList(),
                  onChanged: (value) => setState(() => selectedDepartmentId = value ?? selectedDepartmentId),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Class name'),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Enter class name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: batchController,
                  decoration: const InputDecoration(labelText: 'Batch'),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Enter batch' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(
                  context,
                  AcademicClass(
                    id: initialValue?.id ?? '',
                    departmentId: selectedDepartmentId,
                    name: nameController.text.trim(),
                    batch: batchController.text.trim(),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}

Future<StudentRecord?> showStudentDialog(
  BuildContext context,
  List<AcademicClass> classes, {
  StudentRecord? initialValue,
}) async {
  final rollController = TextEditingController(text: initialValue?.rollNo ?? '');
  final nameController = TextEditingController(text: initialValue?.name ?? '');
  final genderController = TextEditingController(text: initialValue?.gender ?? '');
  final personalMobileController = TextEditingController(text: initialValue?.personalMobile ?? '');
  final parentsMobileController = TextEditingController(text: initialValue?.parentsMobile ?? '');
  final emailController = TextEditingController(text: initialValue?.personalEmail ?? '');
  final linkedinController = TextEditingController(text: initialValue?.linkedinProfile ?? '');
  final sscController = TextEditingController(text: initialValue?.sscPercentage.toString() ?? '0');
  final hscController = TextEditingController(text: initialValue?.hscPercentage.toString() ?? '0');
  final diplomaController = TextEditingController(text: initialValue?.diplomaPercentage.toString() ?? '0');
  final semestersControllers = List.generate(
    8,
    (index) => TextEditingController(text: initialValue?.semesters[index].toString() ?? '0'),
  );
  final coursesController = TextEditingController(text: initialValue?.courses ?? '');
  final internshipsController = TextEditingController(text: initialValue?.internships ?? '');
  final trainingsController = TextEditingController(text: initialValue?.trainings ?? '');
  final skillsetController = TextEditingController(text: initialValue?.skillset ?? '');
  final photoController = TextEditingController(text: initialValue?.photoUrl ?? '');
  final formKey = GlobalKey<FormState>();
  var selectedClassId = initialValue?.classId ?? (classes.isNotEmpty ? classes.first.id : '');
  var selectedInterest = initialValue?.preferredInterest ?? PreferredInterest.job;

  return showDialog<StudentRecord>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(initialValue == null ? 'Add Student' : 'Edit Student'),
        content: SizedBox(
          width: 680,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedClassId,
                    decoration: const InputDecoration(labelText: 'Class'),
                    items: classes
                        .map((academicClass) => DropdownMenuItem(value: academicClass.id, child: Text('${academicClass.name} (${academicClass.batch})')))
                        .toList(),
                    onChanged: (value) => setState(() => selectedClassId = value ?? selectedClassId),
                  ),
                  const SizedBox(height: 16),
                  _twoColumnRow(rollController, nameController, 'Roll No', 'Student name'),
                  const SizedBox(height: 16),
                  _twoColumnRow(genderController, personalMobileController, 'Gender', 'Personal mobile'),
                  const SizedBox(height: 16),
                  _twoColumnRow(parentsMobileController, emailController, 'Parents mobile', 'Personal email'),
                  const SizedBox(height: 16),
                  TextFormField(controller: linkedinController, decoration: const InputDecoration(labelText: 'LinkedIn profile link')),
                  const SizedBox(height: 16),
                  _threeColumnRow(sscController, hscController, diplomaController, 'SSC %', 'HSC %', 'Diploma %'),
                  const SizedBox(height: 16),
                  for (var start = 0; start < 8; start += 2) ...[
                    _twoColumnRow(
                      semestersControllers[start],
                      semestersControllers[start + 1],
                      '${start + 1} Sem',
                      '${start + 2} Sem',
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(controller: coursesController, decoration: const InputDecoration(labelText: 'Courses completed'), maxLines: 2),
                  const SizedBox(height: 16),
                  TextFormField(controller: internshipsController, decoration: const InputDecoration(labelText: 'Internships completed'), maxLines: 2),
                  const SizedBox(height: 16),
                  TextFormField(controller: trainingsController, decoration: const InputDecoration(labelText: 'Trainings completed'), maxLines: 2),
                  const SizedBox(height: 16),
                  TextFormField(controller: skillsetController, decoration: const InputDecoration(labelText: 'Skillset'), maxLines: 2),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<PreferredInterest>(
                    value: selectedInterest,
                    decoration: const InputDecoration(labelText: 'Preferred interest'),
                    items: PreferredInterest.values
                        .map((interest) => DropdownMenuItem(value: interest, child: Text(preferredInterestLabel(interest))))
                        .toList(),
                    onChanged: (value) => setState(() => selectedInterest = value ?? selectedInterest),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(controller: photoController, decoration: const InputDecoration(labelText: 'Photo URL / path')),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(
                  context,
                  StudentRecord(
                    id: initialValue?.id ?? '',
                    classId: selectedClassId,
                    rollNo: rollController.text.trim(),
                    name: nameController.text.trim(),
                    gender: genderController.text.trim(),
                    personalMobile: personalMobileController.text.trim(),
                    parentsMobile: parentsMobileController.text.trim(),
                    personalEmail: emailController.text.trim(),
                    linkedinProfile: linkedinController.text.trim(),
                    sscPercentage: _toDouble(sscController.text),
                    hscPercentage: _toDouble(hscController.text),
                    diplomaPercentage: _toDouble(diplomaController.text),
                    semesters: semestersControllers.map((item) => _toDouble(item.text)).toList(),
                    courses: coursesController.text.trim(),
                    internships: internshipsController.text.trim(),
                    trainings: trainingsController.text.trim(),
                    skillset: skillsetController.text.trim(),
                    preferredInterest: selectedInterest,
                    photoUrl: photoController.text.trim(),
                    appliedOpportunityIds: initialValue?.appliedOpportunityIds ?? const [],
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}

Widget _twoColumnRow(
  TextEditingController first,
  TextEditingController second,
  String firstLabel,
  String secondLabel,
) {
  return Row(
    children: [
      Expanded(child: TextFormField(controller: first, decoration: InputDecoration(labelText: firstLabel))),
      const SizedBox(width: 16),
      Expanded(child: TextFormField(controller: second, decoration: InputDecoration(labelText: secondLabel))),
    ],
  );
}

Widget _threeColumnRow(
  TextEditingController first,
  TextEditingController second,
  TextEditingController third,
  String firstLabel,
  String secondLabel,
  String thirdLabel,
) {
  return Row(
    children: [
      Expanded(child: TextFormField(controller: first, decoration: InputDecoration(labelText: firstLabel))),
      const SizedBox(width: 12),
      Expanded(child: TextFormField(controller: second, decoration: InputDecoration(labelText: secondLabel))),
      const SizedBox(width: 12),
      Expanded(child: TextFormField(controller: third, decoration: InputDecoration(labelText: thirdLabel))),
    ],
  );
}

Future<Opportunity?> showOpportunityDialog(
  BuildContext context,
  List<String> batches, {
  Opportunity? initialValue,
}) async {
  final titleController = TextEditingController(text: initialValue?.title ?? '');
  final companyController = TextEditingController(text: initialValue?.company ?? '');
  final descriptionController = TextEditingController(text: initialValue?.description ?? '');
  final packageController = TextEditingController(text: initialValue?.packageLpa.toString() ?? '0');
  final formKey = GlobalKey<FormState>();
  var selectedType = initialValue?.type ?? OpportunityType.job;
  var selectedBatch = initialValue?.batch ?? (batches.isNotEmpty ? batches.first : '2022-2026');

  return showDialog<Opportunity>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(initialValue == null ? 'Post Opportunity' : 'Edit Opportunity'),
        content: SizedBox(
          width: 520,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Enter title' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: companyController,
                  decoration: const InputDecoration(labelText: 'Company'),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Enter company' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<OpportunityType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Opening type'),
                  items: OpportunityType.values
                      .map((type) => DropdownMenuItem(value: type, child: Text(type == OpportunityType.job ? 'Job' : 'Internship')))
                      .toList(),
                  onChanged: (value) => setState(() => selectedType = value ?? selectedType),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedBatch,
                  decoration: const InputDecoration(labelText: 'Batch'),
                  items: batches.map((batch) => DropdownMenuItem(value: batch, child: Text(batch))).toList(),
                  onChanged: (value) => setState(() => selectedBatch = value ?? selectedBatch),
                ),
                const SizedBox(height: 16),
                TextFormField(controller: packageController, decoration: const InputDecoration(labelText: 'Package / stipend (LPA)')),
                const SizedBox(height: 16),
                TextFormField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(
                  context,
                  Opportunity(
                    id: initialValue?.id ?? '',
                    title: titleController.text.trim(),
                    company: companyController.text.trim(),
                    type: selectedType,
                    batch: selectedBatch,
                    description: descriptionController.text.trim(),
                    packageLpa: _toDouble(packageController.text),
                    postedBy: initialValue?.postedBy ?? UserRole.tpOfficer,
                    applicantIds: initialValue?.applicantIds ?? const [],
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}

class CsvImportResult {
  const CsvImportResult({required this.classId, required this.csvText});

  final String classId;
  final String csvText;
}

Future<CsvImportResult?> showCsvImportDialog(BuildContext context, List<AcademicClass> classes) async {
  final csvController = TextEditingController(text: studentCsvTemplate);
  var selectedClassId = classes.isNotEmpty ? classes.first.id : '';
  return showDialog<CsvImportResult>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Bulk CSV Import'),
        content: SizedBox(
          width: 700,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedClassId,
                decoration: const InputDecoration(labelText: 'Import into class'),
                items: classes
                    .map((academicClass) => DropdownMenuItem(value: academicClass.id, child: Text('${academicClass.name} (${academicClass.batch})')))
                    .toList(),
                onChanged: (value) => setState(() => selectedClassId = value ?? selectedClassId),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: csvController,
                maxLines: 14,
                decoration: const InputDecoration(labelText: 'Paste CSV content'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, CsvImportResult(classId: selectedClassId, csvText: csvController.text)),
            child: const Text('Import'),
          ),
        ],
      ),
    ),
  );
}

void _showPreviewDialog(BuildContext context, String title, String content) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 700,
        child: SingleChildScrollView(child: SelectableText(content)),
      ),
      actions: [
        FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
      ],
    ),
  );
}

double _toDouble(String value) => double.tryParse(value.trim()) ?? 0;

PreferredInterest _preferredInterestFromLabel(String value) {
  final normalized = value.toLowerCase();
  if (normalized.contains('business')) {
    return PreferredInterest.business;
  }
  if (normalized.contains('higher')) {
    return PreferredInterest.higherStudies;
  }
  return PreferredInterest.job;
}

String roleLabel(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return 'Admin';
    case UserRole.principal:
      return 'Principal';
    case UserRole.tpOfficer:
      return 'TP Officer';
    case UserRole.coordinator:
      return 'TP Departmental Coordinator';
    case UserRole.student:
      return 'Student';
  }
}

String preferredInterestLabel(PreferredInterest interest) {
  switch (interest) {
    case PreferredInterest.business:
      return 'Business';
    case PreferredInterest.job:
      return 'Job';
    case PreferredInterest.higherStudies:
      return 'Higher Studies';
  }
}

String initials(String value) {
  final parts = value.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
  if (parts.isEmpty) {
    return '?';
  }
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

const studentCsvTemplate = '''Roll No,Name of the Student,Gender,Personal Mobile,Parents Mobile,Personal Email ID,Linkedin Profile Link,SSC %,HSC %,Diploma %,1st Sem,2nd Sem,3rd Sem,4th Sem,5th Sem,6th Sem,7th Sem,8th Sem,Courses,Internships,Trainings,Skillset,Preferred Interest,Photo
CS301,Riya Sharma,Female,9876543211,9898989898,riya@example.com,https://linkedin.com/in/riya,88,85,0,8.1,8.2,8.3,8.4,8.5,8.6,8.7,8.8,Flutter; AWS,Web Intern,CRT,Flutter; Dart; Firebase,Job,https://example.com/photo.jpg''';
