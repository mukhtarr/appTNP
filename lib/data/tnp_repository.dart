import '../core/models.dart';
import 'tnp_api.dart';

class TnpRepository {
  const TnpRepository({required this.api});

  final TnpApi api;

  List<Department> getDepartments() => api.getDepartments();
  List<ClassSection> getClasses() => api.getClasses();
  List<StudentRecord> getStudents() => api.getStudents();
  List<UserAccount> getUsers() => api.getUsers();
  List<Opportunity> getOpportunities() => api.getOpportunities();
  List<OpportunityApplication> getApplications() => api.getApplications();

  void upsertDepartment(Department department) => api.upsertDepartment(department);
  void deleteDepartment(String departmentId) => api.deleteDepartment(departmentId);
  void upsertClass(ClassSection classSection) => api.upsertClass(classSection);
  void deleteClass(String classId) => api.deleteClass(classId);
  void upsertStudent(StudentRecord student) => api.upsertStudent(student);
  void deleteStudent(String studentId) => api.deleteStudent(studentId);
  void upsertUser(UserAccount user) => api.upsertUser(user);
  void upsertOpportunity(Opportunity opportunity) => api.upsertOpportunity(opportunity);
  void deleteOpportunity(String opportunityId) => api.deleteOpportunity(opportunityId);
  void upsertApplication(OpportunityApplication application) => api.upsertApplication(application);
}
