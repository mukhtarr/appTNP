import 'package:flutter/material.dart';

import '../core/models.dart';
import '../core/validators.dart';
import '../data/tnp_repository.dart';

class AppController extends ChangeNotifier {
  AppController({required this.repository});

  final TnpRepository repository;

  ThemeMode themeMode = ThemeMode.light;
  AppModule selectedModule = AppModule.dashboard;
  UserAccount? currentUser;
  String studentSearchQuery = '';
  String dashboardSearchQuery = '';

  List<Department> get departments => repository.getDepartments();
  List<ClassSection> get classes => repository.getClasses();
  List<StudentRecord> get students => _filterStudents(repository.getStudents());
  List<StudentRecord> get allStudents => repository.getStudents();
  List<UserAccount> get users => repository.getUsers();
  List<Opportunity> get opportunities => _visibleOpportunities(repository.getOpportunities());
  List<Opportunity> get allOpportunities => repository.getOpportunities();
  List<OpportunityApplication> get applications => repository.getApplications();

  List<AppModule> get visibleModules {
    final role = currentUser?.role ?? UserRole.admin;
    switch (role) {
      case UserRole.admin:
        return AppModule.values;
      case UserRole.principal:
        return const [
          AppModule.dashboard,
          AppModule.students,
          AppModule.opportunities,
          AppModule.exports,
          AppModule.profile,
        ];
      case UserRole.tpOfficer:
        return const [
          AppModule.dashboard,
          AppModule.students,
          AppModule.opportunities,
          AppModule.exports,
          AppModule.profile,
        ];
      case UserRole.departmentCoordinator:
        return const [
          AppModule.dashboard,
          AppModule.students,
          AppModule.opportunities,
          AppModule.exports,
          AppModule.profile,
        ];
      case UserRole.student:
        return const [AppModule.dashboard, AppModule.opportunities, AppModule.profile];
    }
  }

  DashboardMetrics get metrics {
    final scopedStudents = _scopeStudents(repository.getStudents());
    final scopedDepartments = _scopeDepartments(repository.getDepartments());
    final scopedOpportunities = _visibleOpportunities(repository.getOpportunities());
    final batchCounts = <String, int>{};
    final departmentCounts = <String, int>{};
    final recruiterCount = <String, int>{};
    final yearCounts = <String, int>{};
    var highestPackage = 0.0;
    var placed = 0;
    var internship = 0;
    var higherStudies = 0;

    for (final student in scopedStudents) {
      batchCounts.update(student.batch, (value) => value + 1, ifAbsent: () => 1);
      final departmentLabel = departmentName(student.departmentId);
      departmentCounts.update(departmentLabel, (value) => value + 1, ifAbsent: () => 1);
      for (final placement in student.placementHistory) {
        recruiterCount.update(placement.organization, (value) => value + 1, ifAbsent: () => 1);
        yearCounts.update(placement.year.toString(), (value) => value + 1, ifAbsent: () => 1);
        highestPackage = placement.packageLpa > highestPackage ? placement.packageLpa : highestPackage;
        if (placement.stage == PlacementStage.placed) {
          placed++;
        } else if (placement.stage == PlacementStage.internship) {
          internship++;
        } else if (placement.stage == PlacementStage.higherStudies) {
          higherStudies++;
        }
      }
    }

    var topRecruiter = 'N/A';
    var recruiterHits = 0;
    recruiterCount.forEach((key, value) {
      if (value > recruiterHits) {
        recruiterHits = value;
        topRecruiter = key;
      }
    });

    return DashboardMetrics(
      totalStudents: scopedStudents.length,
      totalDepartments: scopedDepartments.length,
      totalOpenOpportunities:
          scopedOpportunities.where((item) => item.status == OpportunityStatus.open).length,
      placedStudents: placed,
      internshipStudents: internship,
      higherStudiesStudents: higherStudies,
      highestPackage: highestPackage,
      topRecruiter: topRecruiter,
      batchCounts: batchCounts,
      departmentCounts: departmentCounts,
      yearCounts: yearCounts,
    );
  }

  StudentRecord? get currentStudentProfile {
    final studentId = currentUser?.studentId;
    if (studentId == null) {
      return null;
    }
    for (final student in repository.getStudents()) {
      if (student.id == studentId) {
        return student;
      }
    }
    return null;
  }

  List<OpportunityApplication> get currentStudentApplications {
    final studentId = currentUser?.studentId;
    if (studentId == null) {
      return const [];
    }
    return repository
        .getApplications()
        .where((item) => item.studentId == studentId)
        .toList(growable: false);
  }

  List<StudentRecord> get dashboardSearchResults {
    final query = dashboardSearchQuery.trim().toLowerCase();
    final scopedStudents = _scopeStudents(repository.getStudents());
    if (query.isEmpty) {
      return scopedStudents;
    }
    return scopedStudents.where((student) {
      final haystack = [
        student.rollNo,
        student.name,
        departmentName(student.departmentId),
        className(student.classId),
        student.batch,
        student.skillset.join(' '),
        student.preferredInterest.label,
        student.placementHistory.map((item) => item.stage.name).join(' '),
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList(growable: false);
  }

  void toggleTheme() {
    themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void selectModule(AppModule module) {
    selectedModule = module;
    notifyListeners();
  }

  void updateStudentSearch(String query) {
    studentSearchQuery = query;
    notifyListeners();
  }

  void updateDashboardSearch(String query) {
    dashboardSearchQuery = query;
    notifyListeners();
  }

  void login(String email, String password) {
    final normalizedEmail = email.trim().toLowerCase();
    UserAccount? matchedUser;
    for (final account in users) {
      if (account.email.toLowerCase() == normalizedEmail && account.password == password) {
        matchedUser = account;
        break;
      }
    }
    if (matchedUser == null) {
      throw StateError('Invalid credentials.');
    }
    currentUser = matchedUser;
    selectedModule = visibleModules.first;
    notifyListeners();
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }

  void register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? departmentId,
  }) {
    repository.upsertUser(
      UserAccount(
        id: _nextId('usr'),
        name: name.trim(),
        email: email.trim(),
        password: password,
        role: role,
        departmentId: departmentId,
      ),
    );
    login(email, password);
  }

  void upsertDepartment({String? id, required String name}) {
    _requireAdmin();
    repository.upsertDepartment(Department(id: id ?? _nextId('dep'), name: name));
    notifyListeners();
  }

  void deleteDepartment(String id) {
    _requireAdmin();
    repository.deleteDepartment(id);
    notifyListeners();
  }

  void upsertClass({
    String? id,
    required String departmentId,
    required String name,
    required String batch,
  }) {
    _requireAdmin();
    repository.upsertClass(
      ClassSection(
        id: id ?? _nextId('cls'),
        departmentId: departmentId,
        name: name,
        batch: batch,
      ),
    );
    notifyListeners();
  }

  void deleteClass(String id) {
    _requireAdmin();
    repository.deleteClass(id);
    notifyListeners();
  }

  void upsertStudent(StudentRecord student) {
    _requireStudentManagers();
    repository.upsertStudent(_enforceCoordinatorScope(student));
    notifyListeners();
  }

  void deleteStudent(String id) {
    _requireStudentManagers();
    final student = allStudents.firstWhere((item) => item.id == id);
    if (_isCoordinator && student.departmentId != currentUser?.departmentId) {
      throw StateError('Department coordinators can manage only their department students.');
    }
    repository.deleteStudent(id);
    notifyListeners();
  }

  CsvImportResult importStudentsFromCsv(String csvData) {
    _requireStudentManagers();
    final lines = csvData.trim().split(RegExp(r'\r?\n'));
    if (lines.length <= 1) {
      throw FormatException('CSV must include a header and at least one student row.');
    }

    final headers = _parseCsvLine(lines.first);
    final added = <StudentRecord>[];
    final errors = <String>[];

    for (var lineIndex = 1; lineIndex < lines.length; lineIndex++) {
      final rawLine = lines[lineIndex].trim();
      if (rawLine.isEmpty) {
        continue;
      }
      try {
        final values = _parseCsvLine(rawLine);
        if (values.length != headers.length) {
          throw FormatException('Column count mismatch.');
        }
        final row = <String, String>{};
        for (var i = 0; i < headers.length; i++) {
          row[headers[i]] = values[i];
        }
        final departmentId = _departmentIdByName(row['Department'] ?? '');
        final batch = row['Batch'] ?? '';
        final classId = _classIdByName(
          departmentId: departmentId,
          className: row['Class'] ?? '',
          batch: batch,
        );
        final student = StudentRecord(
          id: _nextId('stu'),
          rollNo: row['Roll No'] ?? '',
          departmentId: departmentId,
          classId: classId,
          batch: batch,
          name: row['Name of the Student'] ?? '',
          gender: row['Gender'] ?? '',
          personalMobile: row['Personal Mobile'] ?? '',
          parentMobile: row['Parents Mobile'] ?? '',
          personalEmail: row['Personal Email ID'] ?? '',
          linkedinProfile: row['Linkedin Profile Link'] ?? '',
          sscPercentage: double.parse(row['SSC %'] ?? '0'),
          hscPercentage: _tryParseDouble(row['HSC %']),
          diplomaPercentage: _tryParseDouble(row['Diploma %']),
          semesterScores: List<double?>.generate(
            8,
            (index) => _tryParseDouble(row['${index + 1} Sem']),
          ),
          courses: AppValidators.parseListField(row['Courses'] ?? ''),
          internships: AppValidators.parseListField(row['Internships'] ?? ''),
          trainings: AppValidators.parseListField(row['Trainings'] ?? ''),
          skillset: AppValidators.parseListField(row['Skillset'] ?? ''),
          preferredInterest: _interestFromLabel(row['Preferred Interest'] ?? ''),
          photoUrl: row['Photo'] ?? '',
          placementHistory: const [],
        );
        upsertStudent(student);
        added.add(student);
      } catch (error) {
        errors.add('Row ${lineIndex + 1}: $error');
      }
    }

    return CsvImportResult(addedStudents: added, errors: errors);
  }

  String get sampleCsvTemplate => [
        'Department,Class,Batch,Roll No,Name of the Student,Gender,Personal Mobile,Parents Mobile,Personal Email ID,Linkedin Profile Link,SSC %,HSC %,Diploma %,1 Sem,2 Sem,3 Sem,4 Sem,5 Sem,6 Sem,7 Sem,8 Sem,Courses,Internships,Trainings,Skillset,Preferred Interest,Photo',
        'Computer,TY-A,2022-2026,CSE22011,Riya Patil,Female,9876500011,9876500012,riya@student.app,https://linkedin.com/in/riya-patil,88.5,82.5,,8.4,8.5,8.7,8.9,9.0,9.1,,,AWS Cloud Practitioner;Flutter UI,Campus App Intern,Soft Skills Bootcamp,Flutter;REST API;Firebase,Job,https://example.com/riya.jpg',
      ].join('\n');

  ExportBundle exportBatchData({
    required String format,
    String? departmentId,
    String? batch,
    String? classId,
    String? placementStatus,
  }) {
    final rows = _scopeStudents(repository.getStudents()).where((student) {
      final matchesDepartment =
          departmentId == null || departmentId.isEmpty || student.departmentId == departmentId;
      final matchesBatch = batch == null || batch.isEmpty || student.batch == batch;
      final matchesClass = classId == null || classId.isEmpty || student.classId == classId;
      final status = student.placementHistory.isEmpty
          ? 'unplaced'
          : student.placementHistory.last.stage.name.toLowerCase();
      final matchesStatus =
          placementStatus == null || placementStatus.isEmpty || status == placementStatus.toLowerCase();
      return matchesDepartment && matchesBatch && matchesClass && matchesStatus;
    }).toList(growable: false);

    if (format.toLowerCase() == 'excel') {
      final buffer = StringBuffer('Roll No,Name,Department,Class,Batch,Email,Mobile,Interest\n');
      for (final student in rows) {
        buffer.writeln(
          '${student.rollNo},${student.name},${departmentName(student.departmentId)},${className(student.classId)},${student.batch},${student.personalEmail},${student.personalMobile},${student.preferredInterest.label}',
        );
      }
      return ExportBundle(
        format: 'Excel',
        title: 'Batch Export Spreadsheet',
        content: buffer.toString(),
      );
    }

    final buffer = StringBuffer()
      ..writeln('Training and Placement Cell - Batch Export')
      ..writeln('Students: ${rows.length}')
      ..writeln('Highest Package: ${metrics.highestPackage.toStringAsFixed(1)} LPA')
      ..writeln('Top Recruiter: ${metrics.topRecruiter}')
      ..writeln('---');
    for (final student in rows) {
      buffer.writeln(
        '${student.rollNo} | ${student.name} | ${departmentName(student.departmentId)} | ${student.batch}',
      );
    }
    return ExportBundle(format: 'PDF', title: 'Batch Export Report', content: buffer.toString());
  }

  void upsertOpportunity(Opportunity opportunity) {
    _requireOpportunityManagers();
    if (_isCoordinator) {
      final coordinatorDepartment = currentUser?.departmentId;
      if (coordinatorDepartment != null &&
          !opportunity.departmentIds.contains(coordinatorDepartment)) {
        throw StateError('Department coordinators can publish only for their department.');
      }
    }
    repository.upsertOpportunity(opportunity);
    notifyListeners();
  }

  void deleteOpportunity(String id) {
    _requireOpportunityManagers();
    repository.deleteOpportunity(id);
    notifyListeners();
  }

  void applyToOpportunity({required String opportunityId, required String note}) {
    final student = currentStudentProfile;
    if (student == null) {
      throw StateError('Only students can apply for opportunities.');
    }
    repository.upsertApplication(
      OpportunityApplication(
        id: _nextId('app'),
        opportunityId: opportunityId,
        studentId: student.id,
        status: ApplicationStatus.applied,
        appliedAt: DateTime.now(),
        note: note,
      ),
    );
    notifyListeners();
  }

  void updateApplicationStatus(String applicationId, ApplicationStatus status) {
    _requireOpportunityManagers();
    final current = applications.firstWhere((item) => item.id == applicationId);
    repository.upsertApplication(current.copyWith(status: status));
    notifyListeners();
  }

  String departmentName(String departmentId) {
    for (final department in repository.getDepartments()) {
      if (department.id == departmentId) {
        return department.name;
      }
    }
    return 'Unknown';
  }

  String className(String classId) {
    for (final classSection in repository.getClasses()) {
      if (classSection.id == classId) {
        return '${classSection.name} (${classSection.batch})';
      }
    }
    return 'Unknown';
  }

  List<ClassSection> classesForDepartment(String? departmentId) {
    final scopedClasses = _scopeClasses(repository.getClasses());
    if (departmentId == null || departmentId.isEmpty) {
      return scopedClasses;
    }
    return scopedClasses
        .where((item) => item.departmentId == departmentId)
        .toList(growable: false);
  }

  bool get isAdmin => currentUser?.role == UserRole.admin;

  bool get isStudentManager => currentUser != null &&
      {UserRole.admin, UserRole.tpOfficer, UserRole.departmentCoordinator}
          .contains(currentUser!.role);

  bool get canManageOpportunities => currentUser != null &&
      {UserRole.admin, UserRole.tpOfficer, UserRole.departmentCoordinator}
          .contains(currentUser!.role);

  bool get canExport => currentUser?.role != UserRole.student;

  bool get _isCoordinator => currentUser?.role == UserRole.departmentCoordinator;

  StudentRecord _enforceCoordinatorScope(StudentRecord student) {
    if (_isCoordinator) {
      final departmentId = currentUser?.departmentId;
      if (departmentId != null && student.departmentId != departmentId) {
        throw StateError('Department coordinators can manage only their department students.');
      }
    }
    return student;
  }

  List<StudentRecord> _scopeStudents(List<StudentRecord> source) {
    if (_isCoordinator) {
      return source
          .where((item) => item.departmentId == currentUser?.departmentId)
          .toList(growable: false);
    }
    if (currentUser?.role == UserRole.student && currentUser?.studentId != null) {
      return source.where((item) => item.id == currentUser?.studentId).toList(growable: false);
    }
    return source;
  }

  List<Department> _scopeDepartments(List<Department> source) {
    if (_isCoordinator && currentUser?.departmentId != null) {
      return source.where((item) => item.id == currentUser?.departmentId).toList(growable: false);
    }
    return source;
  }

  List<ClassSection> _scopeClasses(List<ClassSection> source) {
    if (_isCoordinator && currentUser?.departmentId != null) {
      return source
          .where((item) => item.departmentId == currentUser?.departmentId)
          .toList(growable: false);
    }
    return source;
  }

  List<StudentRecord> _filterStudents(List<StudentRecord> source) {
    final scoped = _scopeStudents(source);
    final query = studentSearchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return scoped;
    }
    return scoped.where((student) {
      final haystack = [
        student.rollNo,
        student.name,
        student.personalEmail,
        student.personalMobile,
        student.skillset.join(' '),
        student.batch,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList(growable: false);
  }

  List<Opportunity> _visibleOpportunities(List<Opportunity> source) {
    if (currentUser?.role == UserRole.student) {
      final student = currentStudentProfile;
      if (student == null) {
        return const [];
      }
      return source.where((opportunity) {
        return opportunity.status == OpportunityStatus.open &&
            opportunity.departmentIds.contains(student.departmentId) &&
            opportunity.batches.contains(student.batch);
      }).toList(growable: false);
    }
    if (_isCoordinator && currentUser?.departmentId != null) {
      return source
          .where((opportunity) => opportunity.departmentIds.contains(currentUser!.departmentId))
          .toList(growable: false);
    }
    return source;
  }

  void _requireAdmin() {
    if (!isAdmin) {
      throw StateError('Only admins can manage departments and classes.');
    }
  }

  void _requireStudentManagers() {
    if (!isStudentManager) {
      throw StateError('You do not have permission to manage students.');
    }
  }

  void _requireOpportunityManagers() {
    if (!canManageOpportunities) {
      throw StateError('You do not have permission to manage opportunities.');
    }
  }

  String _nextId(String prefix) => '$prefix-${DateTime.now().microsecondsSinceEpoch}';

  String _departmentIdByName(String departmentName) {
    final normalized = departmentName.trim().toLowerCase();
    for (final department in repository.getDepartments()) {
      if (department.name.toLowerCase() == normalized) {
        return department.id;
      }
    }
    throw StateError('Department "${departmentName.trim()}" not found.');
  }

  String _classIdByName({
    required String departmentId,
    required String className,
    required String batch,
  }) {
    final normalizedClass = className.trim().toLowerCase();
    final normalizedBatch = batch.trim();
    for (final classSection in classesForDepartment(departmentId)) {
      if (classSection.name.toLowerCase() == normalizedClass &&
          classSection.batch == normalizedBatch) {
        return classSection.id;
      }
    }
    throw StateError('Class "${className.trim()}" for batch "$normalizedBatch" not found.');
  }

  StudentInterest _interestFromLabel(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'business') {
      return StudentInterest.business;
    }
    if (normalized == 'higher studies') {
      return StudentInterest.higherStudies;
    }
    return StudentInterest.job;
  }

  double? _tryParseDouble(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return double.parse(value.trim());
  }

  List<String> _parseCsvLine(String line) {
    final values = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;
    for (var index = 0; index < line.length; index++) {
      final character = line[index];
      if (character == '"') {
        inQuotes = !inQuotes;
        continue;
      }
      if (character == ',' && !inQuotes) {
        values.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(character);
      }
    }
    values.add(buffer.toString().trim());
    return values;
  }
}
