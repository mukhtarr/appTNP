import 'package:app_tnp/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppController', () {
    test('seeds departments, classes, students and opportunities', () {
      final controller = AppController();

      expect(controller.departments.length, 7);
      expect(controller.classes, isNotEmpty);
      expect(controller.students, isNotEmpty);
      expect(controller.opportunities, isNotEmpty);
    });

    test('imports students from the csv template', () {
      final controller = AppController();
      final before = controller.students.length;

      final imported = controller.importStudentsFromCsv(
        classId: controller.classes.first.id,
        csvText: studentCsvTemplate,
      );

      expect(imported, 1);
      expect(controller.students.length, before + 1);
      expect(controller.students.last.rollNo, 'CS301');
      expect(controller.students.last.preferredInterest, PreferredInterest.job);
    });

    test('creates a student profile on login and syncs applications', () {
      final controller = AppController();

      controller.login(
        email: 'newstudent@example.com',
        name: 'New Student',
        role: UserRole.student,
      );

      final student = controller.currentStudentProfile();
      expect(student, isNotNull);
      expect(student!.personalEmail, 'newstudent@example.com');

      controller.applyToOpportunity(studentId: student.id, opportunityId: 'opp-2');

      expect(controller.currentStudentProfile()!.appliedOpportunityIds, contains('opp-2'));
      expect(
        controller.opportunities.firstWhere((item) => item.id == 'opp-2').applicantIds,
        contains(student.id),
      );
    });
  });
}
