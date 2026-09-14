import 'package:app_tnp/core/models.dart';
import 'package:app_tnp/data/in_memory_tnp_api.dart';
import 'package:app_tnp/data/tnp_repository.dart';
import 'package:app_tnp/domain/app_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppController', () {
    late AppController controller;

    setUp(() {
      controller = AppController(repository: TnpRepository(api: InMemoryTnpApi()));
    });

    test('starts logged out and supports admin login', () {
      expect(controller.currentUser, isNull);

      controller.login('admin@app.tnp', 'admin123');

      expect(controller.currentUser?.role, UserRole.admin);
      expect(controller.visibleModules.length, AppModule.values.length);
    });

    test('student login limits modules and opportunities by eligibility', () {
      controller.login('student@app.tnp', 'student123');

      expect(controller.currentUser?.role, UserRole.student);
      expect(
        controller.visibleModules,
        const [AppModule.dashboard, AppModule.opportunities, AppModule.profile],
      );
      expect(
        controller.opportunities.every(
          (item) => item.departmentIds.contains(controller.currentStudentProfile!.departmentId),
        ),
        isTrue,
      );
    });

    test('student import reports duplicate roll numbers as row errors', () {
      controller.login('admin@app.tnp', 'admin123');

      final result = controller.importStudentsFromCsv(
        'Department,Class,Batch,Roll No,Name of the Student,Gender,Personal Mobile,Parents Mobile,Personal Email ID,Linkedin Profile Link,SSC %,HSC %,Diploma %,1 Sem,2 Sem,3 Sem,4 Sem,5 Sem,6 Sem,7 Sem,8 Sem,Courses,Internships,Trainings,Skillset,Preferred Interest,Photo\n'
        'Computer,TY-A,2022-2026,CSE22001,Duplicate Student,Male,9876500101,9876500102,duplicate@student.app,https://linkedin.com/in/test,91,85,,8,8,8,8,8,8,,,Course,Internship,Training,Skill,Job,https://example.com/student.jpg',
      );

      expect(result.errors, isNotEmpty);
    });

    test('departments with linked classes cannot be deleted', () {
      controller.login('admin@app.tnp', 'admin123');

      expect(() => controller.deleteDepartment('dep-computer'), throwsStateError);
    });
  });
}
