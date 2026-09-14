import '../core/models.dart';
import '../core/validators.dart';
import 'tnp_api.dart';

class InMemoryTnpApi implements TnpApi {
  InMemoryTnpApi() {
    _seed();
  }

  final List<Department> _departments = [];
  final List<ClassSection> _classes = [];
  final List<StudentRecord> _students = [];
  final List<UserAccount> _users = [];
  final List<Opportunity> _opportunities = [];
  final List<OpportunityApplication> _applications = [];

  @override
  List<OpportunityApplication> getApplications() => List.unmodifiable(_applications);

  @override
  List<ClassSection> getClasses() => List.unmodifiable(_classes);

  @override
  List<Department> getDepartments() => List.unmodifiable(_departments);

  @override
  List<Opportunity> getOpportunities() => List.unmodifiable(_opportunities);

  @override
  List<StudentRecord> getStudents() => List.unmodifiable(_students);

  @override
  List<UserAccount> getUsers() => List.unmodifiable(_users);

  @override
  void deleteClass(String classId) {
    final hasStudents = _students.any((student) => student.classId == classId);
    if (hasStudents) {
      throw StateError('Cannot delete class with linked students.');
    }
    _classes.removeWhere((item) => item.id == classId);
  }

  @override
  void deleteDepartment(String departmentId) {
    final hasClasses = _classes.any((item) => item.departmentId == departmentId);
    final hasStudents = _students.any((item) => item.departmentId == departmentId);
    if (hasClasses || hasStudents) {
      throw StateError('Cannot delete department with linked classes or students.');
    }
    _departments.removeWhere((item) => item.id == departmentId);
  }

  @override
  void deleteOpportunity(String opportunityId) {
    final hasApplications = _applications.any((item) => item.opportunityId == opportunityId);
    if (hasApplications) {
      throw StateError('Cannot delete opportunity with student applications. Close it instead.');
    }
    _opportunities.removeWhere((item) => item.id == opportunityId);
  }

  @override
  void deleteStudent(String studentId) {
    _applications.removeWhere((item) => item.studentId == studentId);
    _users.removeWhere((item) => item.studentId == studentId);
    _students.removeWhere((item) => item.id == studentId);
  }

  @override
  void upsertApplication(OpportunityApplication application) {
    final index = _applications.indexWhere((item) => item.id == application.id);
    if (index == -1) {
      final duplicate = _applications.any(
        (item) => item.studentId == application.studentId && item.opportunityId == application.opportunityId,
      );
      if (duplicate) {
        throw StateError('Student already applied for this opportunity.');
      }
      _applications.add(application);
      return;
    }
    _applications[index] = application;
  }

  @override
  void upsertClass(ClassSection classSection) {
    AppValidators.requireNonEmpty('Class name', classSection.name);
    AppValidators.requireNonEmpty('Batch', classSection.batch);
    final duplicate = _classes.any(
      (item) => item.id != classSection.id &&
          item.departmentId == classSection.departmentId &&
          item.name.toLowerCase() == classSection.name.toLowerCase() &&
          item.batch == classSection.batch,
    );
    if (duplicate) {
      throw StateError('A class with the same department and batch already exists.');
    }
    final index = _classes.indexWhere((item) => item.id == classSection.id);
    if (index == -1) {
      _classes.add(classSection);
    } else {
      _classes[index] = classSection;
    }
  }

  @override
  void upsertDepartment(Department department) {
    AppValidators.requireNonEmpty('Department name', department.name);
    final duplicate = _departments.any(
      (item) => item.id != department.id && item.name.toLowerCase() == department.name.toLowerCase(),
    );
    if (duplicate) {
      throw StateError('Department already exists.');
    }
    final index = _departments.indexWhere((item) => item.id == department.id);
    if (index == -1) {
      _departments.add(department);
    } else {
      _departments[index] = department;
    }
  }

  @override
  void upsertOpportunity(Opportunity opportunity) {
    AppValidators.requireNonEmpty('Opportunity title', opportunity.title);
    AppValidators.requireNonEmpty('Company', opportunity.company);
    AppValidators.requireNonEmpty('Eligibility', opportunity.eligibility);
    AppValidators.requireNonEmpty('Description', opportunity.description);
    final index = _opportunities.indexWhere((item) => item.id == opportunity.id);
    if (index == -1) {
      _opportunities.add(opportunity);
    } else {
      _opportunities[index] = opportunity;
    }
  }

  @override
  void upsertStudent(StudentRecord student) {
    AppValidators.requireNonEmpty('Roll No', student.rollNo);
    AppValidators.requireNonEmpty('Name of the Student', student.name);
    AppValidators.requireNonEmpty('Gender', student.gender);
    AppValidators.requireNonEmpty('Department', student.departmentId);
    AppValidators.requireNonEmpty('Class', student.classId);
    AppValidators.requireNonEmpty('Batch', student.batch);
    AppValidators.validatePhone('Personal Mobile', student.personalMobile);
    AppValidators.validatePhone('Parents Mobile', student.parentMobile);
    AppValidators.validateEmail(student.personalEmail);
    AppValidators.validateUrl('Linkedin Profile Link', student.linkedinProfile);
    AppValidators.validatePhoto(student.photoUrl);
    AppValidators.validatePercentage('SSC %', student.sscPercentage, allowNull: false);
    AppValidators.validatePercentage('HSC %', student.hscPercentage);
    AppValidators.validatePercentage('Diploma %', student.diplomaPercentage);
    for (var index = 0; index < student.semesterScores.length; index++) {
      AppValidators.validatePercentage('${index + 1} Semester Score', student.semesterScores[index]);
    }
    final duplicateRoll = _students.any(
      (item) => item.id != student.id && item.rollNo.toLowerCase() == student.rollNo.toLowerCase(),
    );
    if (duplicateRoll) {
      throw StateError('Roll No must be unique.');
    }
    final index = _students.indexWhere((item) => item.id == student.id);
    if (index == -1) {
      _students.add(student);
    } else {
      _students[index] = student;
    }
  }

  @override
  void upsertUser(UserAccount user) {
    AppValidators.requireNonEmpty('User name', user.name);
    AppValidators.validateEmail(user.email);
    AppValidators.requireNonEmpty('Password', user.password);
    final duplicateEmail = _users.any(
      (item) => item.id != user.id && item.email.toLowerCase() == user.email.toLowerCase(),
    );
    if (duplicateEmail) {
      throw StateError('Email already exists.');
    }
    final index = _users.indexWhere((item) => item.id == user.id);
    if (index == -1) {
      _users.add(user);
    } else {
      _users[index] = user;
    }
  }

  void _seed() {
    _departments.addAll(const [
      Department(id: 'dep-computer', name: 'Computer'),
      Department(id: 'dep-aiml', name: 'CSE(AIML)'),
      Department(id: 'dep-ds', name: 'CSE(DS)'),
      Department(id: 'dep-ecs', name: 'ECS'),
      Department(id: 'dep-ece', name: 'ECE'),
      Department(id: 'dep-ce', name: 'CE'),
      Department(id: 'dep-me', name: 'ME'),
    ]);
    _classes.addAll(const [
      ClassSection(id: 'cls-computer-a', departmentId: 'dep-computer', name: 'TY-A', batch: '2022-2026'),
      ClassSection(id: 'cls-aiml-a', departmentId: 'dep-aiml', name: 'TY-A', batch: '2022-2026'),
      ClassSection(id: 'cls-ds-a', departmentId: 'dep-ds', name: 'TY-A', batch: '2022-2026'),
    ]);
    _students.addAll([
      StudentRecord(
        id: 'stu-1',
        rollNo: 'CSE22001',
        departmentId: 'dep-computer',
        classId: 'cls-computer-a',
        batch: '2022-2026',
        name: 'Aarav Shah',
        gender: 'Male',
        personalMobile: '9876543210',
        parentMobile: '9876543211',
        personalEmail: 'aarav@student.app',
        linkedinProfile: 'https://linkedin.com/in/aarav-shah',
        sscPercentage: 89.4,
        hscPercentage: 86.2,
        diplomaPercentage: null,
        semesterScores: <double?>[8.4, 8.5, 8.8, 9.0, 8.9, 9.1, null, null],
        courses: const ['AWS Cloud Foundations', 'Flutter Advanced UI'],
        internships: const ['Campus ERP Intern'],
        trainings: const ['Java Full Stack Bootcamp'],
        skillset: const ['Flutter', 'Firebase', 'REST API', 'SQL'],
        preferredInterest: StudentInterest.job,
        photoUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e',
        placementHistory: const [
          PlacementRecord(
            id: 'pl-1',
            organization: 'TechNova',
            stage: PlacementStage.internship,
            packageLpa: 0,
            year: 2025,
            title: 'Mobile Intern',
          ),
        ],
      ),
      StudentRecord(
        id: 'stu-2',
        rollNo: 'AIML22007',
        departmentId: 'dep-aiml',
        classId: 'cls-aiml-a',
        batch: '2022-2026',
        name: 'Ishita More',
        gender: 'Female',
        personalMobile: '9876543220',
        parentMobile: '9876543221',
        personalEmail: 'ishita@student.app',
        linkedinProfile: 'https://linkedin.com/in/ishita-more',
        sscPercentage: 91.2,
        hscPercentage: 88.1,
        diplomaPercentage: null,
        semesterScores: <double?>[9.0, 9.1, 9.2, 9.3, 9.2, 9.4, null, null],
        courses: const ['Machine Learning Specialization'],
        internships: const ['Vision AI Intern'],
        trainings: const ['Python Data Analytics'],
        skillset: const ['Python', 'TensorFlow', 'Power BI'],
        preferredInterest: StudentInterest.higherStudies,
        photoUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
        placementHistory: const [
          PlacementRecord(
            id: 'pl-2',
            organization: 'FutureVision Labs',
            stage: PlacementStage.placed,
            packageLpa: 12.5,
            year: 2026,
            title: 'AI Engineer',
          ),
        ],
      ),
    ]);
    _users.addAll(const [
      UserAccount(
        id: 'usr-admin',
        name: 'Admin User',
        email: 'admin@app.tnp',
        password: 'admin123',
        role: UserRole.admin,
      ),
      UserAccount(
        id: 'usr-principal',
        name: 'Principal User',
        email: 'principal@app.tnp',
        password: 'principal123',
        role: UserRole.principal,
      ),
      UserAccount(
        id: 'usr-officer',
        name: 'TP Officer',
        email: 'officer@app.tnp',
        password: 'officer123',
        role: UserRole.tpOfficer,
      ),
      UserAccount(
        id: 'usr-coordinator',
        name: 'Department Coordinator',
        email: 'coordinator@app.tnp',
        password: 'coordinator123',
        role: UserRole.departmentCoordinator,
        departmentId: 'dep-computer',
      ),
      UserAccount(
        id: 'usr-student',
        name: 'Aarav Shah',
        email: 'student@app.tnp',
        password: 'student123',
        role: UserRole.student,
        departmentId: 'dep-computer',
        studentId: 'stu-1',
      ),
    ]);
    _opportunities.addAll([
      Opportunity(
        id: 'opp-1',
        title: 'Flutter Developer',
        company: 'TechNova',
        type: OpportunityType.job,
        status: OpportunityStatus.open,
        location: 'Pune',
        salaryPackage: 8.5,
        stipend: null,
        deadline: DateTime.now().add(const Duration(days: 15)),
        eligibility: 'CGPA 7.5+, Flutter or Android project experience',
        description: 'Hiring mobile developers for campus placements.',
        departmentIds: const ['dep-computer', 'dep-aiml', 'dep-ds'],
        batches: const ['2022-2026'],
        postedByRole: UserRole.tpOfficer,
        postedByName: 'TP Officer',
      ),
      Opportunity(
        id: 'opp-2',
        title: 'Data Science Intern',
        company: 'FutureVision Labs',
        type: OpportunityType.internship,
        status: OpportunityStatus.open,
        location: 'Remote',
        salaryPackage: null,
        stipend: 25000,
        deadline: DateTime.now().add(const Duration(days: 21)),
        eligibility: 'Python, ML basics, batch 2022-2026',
        description: 'Summer internship with PPO opportunity.',
        departmentIds: const ['dep-aiml', 'dep-ds'],
        batches: const ['2022-2026'],
        postedByRole: UserRole.departmentCoordinator,
        postedByName: 'Department Coordinator',
      ),
    ]);
    _applications.addAll([
      OpportunityApplication(
        id: 'app-1',
        opportunityId: 'opp-1',
        studentId: 'stu-1',
        status: ApplicationStatus.shortlisted,
        appliedAt: DateTime.now().subtract(const Duration(days: 4)),
        note: 'Aptitude cleared. Awaiting technical round.',
      ),
    ]);
  }
}
