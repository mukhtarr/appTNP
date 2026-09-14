enum UserRole { admin, principal, tpOfficer, departmentCoordinator, student }

enum OpportunityType { job, internship }

enum OpportunityStatus { open, closed }

enum ApplicationStatus { applied, shortlisted, rejected, selected, joined }

enum StudentInterest { business, job, higherStudies }

enum PlacementStage { placed, internship, higherStudies }

enum AppModule { dashboard, departments, classes, students, opportunities, exports, profile }

class Department {
  const Department({required this.id, required this.name});

  final String id;
  final String name;

  Department copyWith({String? id, String? name}) {
    return Department(id: id ?? this.id, name: name ?? this.name);
  }
}

class ClassSection {
  const ClassSection({
    required this.id,
    required this.departmentId,
    required this.name,
    required this.batch,
  });

  final String id;
  final String departmentId;
  final String name;
  final String batch;

  ClassSection copyWith({
    String? id,
    String? departmentId,
    String? name,
    String? batch,
  }) {
    return ClassSection(
      id: id ?? this.id,
      departmentId: departmentId ?? this.departmentId,
      name: name ?? this.name,
      batch: batch ?? this.batch,
    );
  }
}

class PlacementRecord {
  const PlacementRecord({
    required this.id,
    required this.organization,
    required this.stage,
    required this.packageLpa,
    required this.year,
    required this.title,
  });

  final String id;
  final String organization;
  final PlacementStage stage;
  final double packageLpa;
  final int year;
  final String title;
}

class StudentRecord {
  const StudentRecord({
    required this.id,
    required this.rollNo,
    required this.departmentId,
    required this.classId,
    required this.batch,
    required this.name,
    required this.gender,
    required this.personalMobile,
    required this.parentMobile,
    required this.personalEmail,
    required this.linkedinProfile,
    required this.sscPercentage,
    required this.hscPercentage,
    required this.diplomaPercentage,
    required this.semesterScores,
    required this.courses,
    required this.internships,
    required this.trainings,
    required this.skillset,
    required this.preferredInterest,
    required this.photoUrl,
    required this.placementHistory,
  });

  final String id;
  final String rollNo;
  final String departmentId;
  final String classId;
  final String batch;
  final String name;
  final String gender;
  final String personalMobile;
  final String parentMobile;
  final String personalEmail;
  final String linkedinProfile;
  final double sscPercentage;
  final double? hscPercentage;
  final double? diplomaPercentage;
  final List<double?> semesterScores;
  final List<String> courses;
  final List<String> internships;
  final List<String> trainings;
  final List<String> skillset;
  final StudentInterest preferredInterest;
  final String photoUrl;
  final List<PlacementRecord> placementHistory;

  StudentRecord copyWith({
    String? id,
    String? rollNo,
    String? departmentId,
    String? classId,
    String? batch,
    String? name,
    String? gender,
    String? personalMobile,
    String? parentMobile,
    String? personalEmail,
    String? linkedinProfile,
    double? sscPercentage,
    double? hscPercentage,
    double? diplomaPercentage,
    List<double?>? semesterScores,
    List<String>? courses,
    List<String>? internships,
    List<String>? trainings,
    List<String>? skillset,
    StudentInterest? preferredInterest,
    String? photoUrl,
    List<PlacementRecord>? placementHistory,
  }) {
    return StudentRecord(
      id: id ?? this.id,
      rollNo: rollNo ?? this.rollNo,
      departmentId: departmentId ?? this.departmentId,
      classId: classId ?? this.classId,
      batch: batch ?? this.batch,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      personalMobile: personalMobile ?? this.personalMobile,
      parentMobile: parentMobile ?? this.parentMobile,
      personalEmail: personalEmail ?? this.personalEmail,
      linkedinProfile: linkedinProfile ?? this.linkedinProfile,
      sscPercentage: sscPercentage ?? this.sscPercentage,
      hscPercentage: hscPercentage ?? this.hscPercentage,
      diplomaPercentage: diplomaPercentage ?? this.diplomaPercentage,
      semesterScores: semesterScores ?? this.semesterScores,
      courses: courses ?? this.courses,
      internships: internships ?? this.internships,
      trainings: trainings ?? this.trainings,
      skillset: skillset ?? this.skillset,
      preferredInterest: preferredInterest ?? this.preferredInterest,
      photoUrl: photoUrl ?? this.photoUrl,
      placementHistory: placementHistory ?? this.placementHistory,
    );
  }
}

class UserAccount {
  const UserAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.departmentId,
    this.studentId,
  });

  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final String? departmentId;
  final String? studentId;

  UserAccount copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    UserRole? role,
    String? departmentId,
    String? studentId,
  }) {
    return UserAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      departmentId: departmentId ?? this.departmentId,
      studentId: studentId ?? this.studentId,
    );
  }
}

class Opportunity {
  const Opportunity({
    required this.id,
    required this.title,
    required this.company,
    required this.type,
    required this.status,
    required this.location,
    required this.salaryPackage,
    required this.stipend,
    required this.deadline,
    required this.eligibility,
    required this.description,
    required this.departmentIds,
    required this.batches,
    required this.postedByRole,
    required this.postedByName,
  });

  final String id;
  final String title;
  final String company;
  final OpportunityType type;
  final OpportunityStatus status;
  final String location;
  final double? salaryPackage;
  final double? stipend;
  final DateTime deadline;
  final String eligibility;
  final String description;
  final List<String> departmentIds;
  final List<String> batches;
  final UserRole postedByRole;
  final String postedByName;

  Opportunity copyWith({
    String? id,
    String? title,
    String? company,
    OpportunityType? type,
    OpportunityStatus? status,
    String? location,
    double? salaryPackage,
    double? stipend,
    DateTime? deadline,
    String? eligibility,
    String? description,
    List<String>? departmentIds,
    List<String>? batches,
    UserRole? postedByRole,
    String? postedByName,
  }) {
    return Opportunity(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      type: type ?? this.type,
      status: status ?? this.status,
      location: location ?? this.location,
      salaryPackage: salaryPackage ?? this.salaryPackage,
      stipend: stipend ?? this.stipend,
      deadline: deadline ?? this.deadline,
      eligibility: eligibility ?? this.eligibility,
      description: description ?? this.description,
      departmentIds: departmentIds ?? this.departmentIds,
      batches: batches ?? this.batches,
      postedByRole: postedByRole ?? this.postedByRole,
      postedByName: postedByName ?? this.postedByName,
    );
  }
}

class OpportunityApplication {
  const OpportunityApplication({
    required this.id,
    required this.opportunityId,
    required this.studentId,
    required this.status,
    required this.appliedAt,
    required this.note,
  });

  final String id;
  final String opportunityId;
  final String studentId;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final String note;

  OpportunityApplication copyWith({
    String? id,
    String? opportunityId,
    String? studentId,
    ApplicationStatus? status,
    DateTime? appliedAt,
    String? note,
  }) {
    return OpportunityApplication(
      id: id ?? this.id,
      opportunityId: opportunityId ?? this.opportunityId,
      studentId: studentId ?? this.studentId,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      note: note ?? this.note,
    );
  }
}

class DashboardMetrics {
  const DashboardMetrics({
    required this.totalStudents,
    required this.totalDepartments,
    required this.totalOpenOpportunities,
    required this.placedStudents,
    required this.internshipStudents,
    required this.higherStudiesStudents,
    required this.highestPackage,
    required this.topRecruiter,
    required this.batchCounts,
    required this.departmentCounts,
    required this.yearCounts,
  });

  final int totalStudents;
  final int totalDepartments;
  final int totalOpenOpportunities;
  final int placedStudents;
  final int internshipStudents;
  final int higherStudiesStudents;
  final double highestPackage;
  final String topRecruiter;
  final Map<String, int> batchCounts;
  final Map<String, int> departmentCounts;
  final Map<String, int> yearCounts;
}

class CsvImportResult {
  const CsvImportResult({required this.addedStudents, required this.errors});

  final List<StudentRecord> addedStudents;
  final List<String> errors;
}

class ExportBundle {
  const ExportBundle({required this.format, required this.title, required this.content});

  final String format;
  final String title;
  final String content;
}

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.admin:
        return 'ADMIN';
      case UserRole.principal:
        return 'PRINCIPAL';
      case UserRole.tpOfficer:
        return 'TP OFFICER';
      case UserRole.departmentCoordinator:
        return 'TP DEPARTMENTAL COORDINATOR';
      case UserRole.student:
        return 'STUDENT';
    }
  }
}

extension StudentInterestX on StudentInterest {
  String get label {
    switch (this) {
      case StudentInterest.business:
        return 'Business';
      case StudentInterest.job:
        return 'Job';
      case StudentInterest.higherStudies:
        return 'Higher Studies';
    }
  }
}

extension OpportunityTypeX on OpportunityType {
  String get label => this == OpportunityType.job ? 'Job' : 'Internship';
}

extension OpportunityStatusX on OpportunityStatus {
  String get label => this == OpportunityStatus.open ? 'Open' : 'Closed';
}

extension ApplicationStatusX on ApplicationStatus {
  String get label {
    switch (this) {
      case ApplicationStatus.applied:
        return 'Applied';
      case ApplicationStatus.shortlisted:
        return 'Shortlisted';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.selected:
        return 'Selected';
      case ApplicationStatus.joined:
        return 'Joined';
    }
  }
}

extension AppModuleX on AppModule {
  String get label {
    switch (this) {
      case AppModule.dashboard:
        return 'Dashboard';
      case AppModule.departments:
        return 'Departments';
      case AppModule.classes:
        return 'Classes';
      case AppModule.students:
        return 'Students';
      case AppModule.opportunities:
        return 'Opportunities';
      case AppModule.exports:
        return 'Exports';
      case AppModule.profile:
        return 'Profile';
    }
  }
}
