import '../core/models.dart';

abstract class TnpApi {
  List<Department> getDepartments();
  List<ClassSection> getClasses();
  List<StudentRecord> getStudents();
  List<UserAccount> getUsers();
  List<Opportunity> getOpportunities();
  List<OpportunityApplication> getApplications();

  void upsertDepartment(Department department);
  void deleteDepartment(String departmentId);
  void upsertClass(ClassSection classSection);
  void deleteClass(String classId);
  void upsertStudent(StudentRecord student);
  void deleteStudent(String studentId);
  void upsertUser(UserAccount user);
  void upsertOpportunity(Opportunity opportunity);
  void deleteOpportunity(String opportunityId);
  void upsertApplication(OpportunityApplication application);
}
