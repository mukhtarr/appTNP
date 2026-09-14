import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../core/models.dart';
import '../core/validators.dart';
import '../domain/app_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final currentUser = controller.currentUser;
    if (currentUser == null) {
      return _LoginView(controller: controller);
    }

    final modules = controller.visibleModules;
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            Container(
              width: 260,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'appTNP',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Training & Placement Cell',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  _GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(currentUser.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(currentUser.role.label, style: const TextStyle(color: Colors.white70)),
                        if (currentUser.departmentId != null) ...[
                          const SizedBox(height: 4),
                          Text(controller.departmentName(currentUser.departmentId!), style: const TextStyle(color: Colors.white70)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: ListView.separated(
                      itemCount: modules.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final module = modules[index];
                        final selected = controller.selectedModule == module;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          decoration: BoxDecoration(
                            color: selected ? Colors.white.withOpacity(0.18) : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: ListTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            leading: FaIcon(_moduleIcon(module), color: Colors.white),
                            title: Text(module.label, style: const TextStyle(color: Colors.white)),
                            onTap: () => controller.selectModule(module),
                          ),
                        );
                      },
                    ),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      minimumSize: const Size.fromHeight(54),
                    ),
                    onPressed: controller.logout,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Logout'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _HeaderBar(controller: controller),
                    const SizedBox(height: 18),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        switchInCurve: Curves.easeOutBack,
                        child: KeyedSubtree(
                          key: ValueKey(controller.selectedModule),
                          child: _buildModuleBody(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleBody(BuildContext context) {
    switch (controller.selectedModule) {
      case AppModule.dashboard:
        return _DashboardPanel(controller: controller);
      case AppModule.departments:
        return _DepartmentsPanel(controller: controller);
      case AppModule.classes:
        return _ClassesPanel(controller: controller);
      case AppModule.students:
        return _StudentsPanel(controller: controller);
      case AppModule.opportunities:
        return _OpportunitiesPanel(controller: controller);
      case AppModule.exports:
        return _ExportsPanel(controller: controller);
      case AppModule.profile:
        return _ProfilePanel(controller: controller);
    }
  }

  IconData _moduleIcon(AppModule module) {
    switch (module) {
      case AppModule.dashboard:
        return FontAwesomeIcons.chartLine;
      case AppModule.departments:
        return FontAwesomeIcons.building;
      case AppModule.classes:
        return FontAwesomeIcons.usersRectangle;
      case AppModule.students:
        return FontAwesomeIcons.userGraduate;
      case AppModule.opportunities:
        return FontAwesomeIcons.briefcase;
      case AppModule.exports:
        return FontAwesomeIcons.fileExport;
      case AppModule.profile:
        return FontAwesomeIcons.idCard;
    }
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(controller.selectedModule.label, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                'Batch wise insights, student lifecycle, and recruitment workflows in one portal.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        if (controller.selectedModule == AppModule.dashboard || controller.selectedModule == AppModule.students)
          SizedBox(
            width: 320,
            child: TextField(
              onChanged: controller.selectedModule == AppModule.dashboard ? controller.updateDashboardSearch : controller.updateStudentSearch,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Search students, skills, batch...',
              ),
            ),
          ),
        const SizedBox(width: 12),
        IconButton.filledTonal(
          onPressed: controller.toggleTheme,
          icon: Icon(controller.themeMode == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
        ),
      ],
    );
  }
}

class _DashboardPanel extends StatelessWidget {
  const _DashboardPanel({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final metrics = controller.metrics;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _MetricCard(title: 'Students', value: '${metrics.totalStudents}', subtitle: 'Active batch records', icon: FontAwesomeIcons.users),
              _MetricCard(title: 'Open Opportunities', value: '${metrics.totalOpenOpportunities}', subtitle: 'Jobs & internships live', icon: FontAwesomeIcons.briefcase),
              _MetricCard(title: 'Placed', value: '${metrics.placedStudents}', subtitle: 'Final placement outcomes', icon: FontAwesomeIcons.userCheck),
              _MetricCard(title: 'Internships', value: '${metrics.internshipStudents}', subtitle: 'Internship highlights', icon: FontAwesomeIcons.laptopCode),
              _MetricCard(title: 'Higher Studies', value: '${metrics.higherStudiesStudents}', subtitle: 'Academic progression', icon: FontAwesomeIcons.graduationCap),
              _MetricCard(title: 'Highest Package', value: '${metrics.highestPackage.toStringAsFixed(1)} LPA', subtitle: 'Top offer captured', icon: FontAwesomeIcons.indianRupeeSign),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _SectionCard(
                  title: 'Batch Wise Snapshot',
                  child: Column(
                    children: metrics.batchCounts.entries
                        .map((entry) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.calendar_month_rounded),
                              title: Text(entry.key),
                              trailing: Text('${entry.value} students'),
                            ))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SectionCard(
                  title: 'Year Wise Outcomes',
                  child: Column(
                    children: metrics.yearCounts.entries
                        .map((entry) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.insights_rounded),
                              title: Text(entry.key),
                              trailing: Text('${entry.value} outcomes'),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Department Distribution',
            child: Column(
              children: metrics.departmentCounts.entries
                  .map((entry) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.account_tree_rounded),
                        title: Text(entry.key),
                        trailing: Text('${entry.value} students'),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Student Search Results',
            child: Column(
              children: controller.dashboardSearchResults.take(8).map((student) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(child: Text(student.name.characters.first)),
                  title: Text('${student.name} · ${student.rollNo}'),
                  subtitle: Text('${controller.departmentName(student.departmentId)} · ${student.batch} · ${student.skillset.join(', ')}'),
                  trailing: Text(student.preferredInterest.label),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DepartmentsPanel extends StatelessWidget {
  const _DepartmentsPanel({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Department Master',
      action: FilledButton.icon(
        onPressed: () => _showDepartmentDialog(context, controller),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Department'),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: controller.departments.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final department = controller.departments[index];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(department.name),
            subtitle: Text('${controller.classesForDepartment(department.id).length} classes'),
            trailing: Wrap(
              spacing: 8,
              children: [
                IconButton(
                  onPressed: () => _showDepartmentDialog(context, controller, department: department),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  onPressed: () => _confirmDelete(
                    context,
                    title: 'Delete department?',
                    message: 'Departments can be deleted only when no class or student is linked.',
                    onConfirm: () => controller.deleteDepartment(department.id),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ClassesPanel extends StatelessWidget {
  const _ClassesPanel({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final classes = controller.classesForDepartment(null);
    return _SectionCard(
      title: 'Classes & Batches',
      action: FilledButton.icon(
        onPressed: () => _showClassDialog(context, controller),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Class'),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: classes.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = classes[index];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('${item.name} · ${item.batch}'),
            subtitle: Text(controller.departmentName(item.departmentId)),
            trailing: Wrap(
              spacing: 8,
              children: [
                IconButton(
                  onPressed: () => _showClassDialog(context, controller, classSection: item),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  onPressed: () => _confirmDelete(
                    context,
                    title: 'Delete class?',
                    message: 'Classes can be deleted only when no student is assigned.',
                    onConfirm: () => controller.deleteClass(item.id),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StudentsPanel extends StatelessWidget {
  const _StudentsPanel({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SectionCard(
                title: 'Student Registry',
                action: controller.isStudentManager
                    ? Wrap(
                        spacing: 12,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _showImportDialog(context, controller),
                            icon: const Icon(Icons.upload_file_rounded),
                            label: const Text('Bulk CSV Import'),
                          ),
                          FilledButton.icon(
                            onPressed: () => _showStudentDialog(context, controller),
                            icon: const Icon(Icons.person_add_alt_1_rounded),
                            label: const Text('Add Student'),
                          ),
                        ],
                      )
                    : null,
                child: Column(
                  children: controller.students.map((student) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(radius: 28, child: Text(student.name.characters.first)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(student.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                                      Text('${student.rollNo} · ${controller.departmentName(student.departmentId)} · ${controller.className(student.classId)}'),
                                    ],
                                  ),
                                ),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    Chip(label: Text(student.preferredInterest.label)),
                                    if (controller.isStudentManager) ...[
                                      IconButton(
                                        onPressed: () => _showStudentDialog(context, controller, student: student),
                                        icon: const Icon(Icons.edit_outlined),
                                      ),
                                      IconButton(
                                        onPressed: () => _confirmDelete(
                                          context,
                                          title: 'Delete student?',
                                          message: 'The student profile, linked login, and application history will be removed.',
                                          onConfirm: () => controller.deleteStudent(student.id),
                                        ),
                                        icon: const Icon(Icons.delete_outline),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _InfoChip(label: 'Email', value: student.personalEmail),
                                _InfoChip(label: 'Mobile', value: student.personalMobile),
                                _InfoChip(label: 'SSC', value: '${student.sscPercentage}%'),
                                _InfoChip(label: 'HSC', value: '${student.hscPercentage ?? '-'}%'),
                                _InfoChip(label: 'Skills', value: student.skillset.join(', ')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OpportunitiesPanel extends StatelessWidget {
  const _OpportunitiesPanel({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: controller.currentUser?.role == UserRole.student ? 'Apply for Jobs & Internships' : 'Opportunity Management',
      action: controller.canManageOpportunities
          ? FilledButton.icon(
              onPressed: () => _showOpportunityDialog(context, controller),
              icon: const Icon(Icons.add_business_rounded),
              label: const Text('Post Opportunity'),
            )
          : null,
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: controller.opportunities.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final opportunity = controller.opportunities[index];
          final application = controller.currentStudentApplications.cast<OpportunityApplication?>().firstWhere(
                (item) => item?.opportunityId == opportunity.id,
                orElse: () => null,
              );
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${opportunity.company} · ${opportunity.title}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text('${opportunity.type.label} · ${opportunity.location} · Deadline ${_formatDate(opportunity.deadline)}'),
                          ],
                        ),
                      ),
                      Chip(label: Text(opportunity.status.label)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(label: 'Eligibility', value: opportunity.eligibility),
                      _InfoChip(label: 'Departments', value: opportunity.departmentIds.map(controller.departmentName).join(', ')),
                      _InfoChip(label: 'Batches', value: opportunity.batches.join(', ')),
                      _InfoChip(label: 'Package', value: opportunity.salaryPackage == null ? '-' : '${opportunity.salaryPackage} LPA'),
                      _InfoChip(label: 'Stipend', value: opportunity.stipend == null ? '-' : '₹${opportunity.stipend!.toStringAsFixed(0)}'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(opportunity.description),
                  const SizedBox(height: 14),
                  if (controller.currentUser?.role == UserRole.student)
                    FilledButton.icon(
                      onPressed: application == null ? () => _showApplyDialog(context, controller, opportunity) : null,
                      icon: const Icon(Icons.send_rounded),
                      label: Text(application == null ? 'Apply now' : application.status.label),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _showOpportunityDialog(context, controller, opportunity: opportunity),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _confirmDelete(
                            context,
                            title: 'Delete opportunity?',
                            message: 'Opportunities with applications cannot be deleted and must be closed instead.',
                            onConfirm: () => controller.deleteOpportunity(opportunity.id),
                          ),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Delete'),
                        ),
                        ...controller.applications
                            .where((item) => item.opportunityId == opportunity.id)
                            .map(
                              (application) => PopupMenuButton<ApplicationStatus>(
                                onSelected: (status) => controller.updateApplicationStatus(application.id, status),
                                itemBuilder: (context) => ApplicationStatus.values
                                    .map((status) => PopupMenuItem(value: status, child: Text(status.label)))
                                    .toList(),
                                child: Chip(label: Text('Application ${application.status.label}')),
                              ),
                            ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ExportsPanel extends StatefulWidget {
  const _ExportsPanel({required this.controller});

  final AppController controller;

  @override
  State<_ExportsPanel> createState() => _ExportsPanelState();
}

class _ExportsPanelState extends State<_ExportsPanel> {
  String? selectedDepartmentId;
  String? selectedClassId;
  String? selectedBatch;
  String? selectedPlacementStatus;
  ExportBundle? lastExport;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return _SectionCard(
      title: 'Batch Wise Exports',
      child: Column(
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _DropdownField<String?>(
                value: selectedDepartmentId,
                hint: 'Department',
                items: [const DropdownMenuItem<String?>(value: null, child: Text('All Departments'))] +
                    controller.departments
                        .map((item) => DropdownMenuItem<String?>(value: item.id, child: Text(item.name)))
                        .toList(),
                onChanged: (value) => setState(() {
                  selectedDepartmentId = value;
                  selectedClassId = null;
                }),
              ),
              _DropdownField<String?>(
                value: selectedClassId,
                hint: 'Class',
                items: [const DropdownMenuItem<String?>(value: null, child: Text('All Classes'))] +
                    controller
                        .classesForDepartment(selectedDepartmentId)
                        .map((item) => DropdownMenuItem<String?>(value: item.id, child: Text('${item.name} (${item.batch})')))
                        .toList(),
                onChanged: (value) => setState(() => selectedClassId = value),
              ),
              _DropdownField<String?>(
                value: selectedBatch,
                hint: 'Batch',
                items: [const DropdownMenuItem<String?>(value: null, child: Text('All Batches'))] +
                    controller.allStudents
                        .map((item) => item.batch)
                        .toSet()
                        .map((item) => DropdownMenuItem<String?>(value: item, child: Text(item)))
                        .toList(),
                onChanged: (value) => setState(() => selectedBatch = value),
              ),
              _DropdownField<String?>(
                value: selectedPlacementStatus,
                hint: 'Placement Status',
                items: const [
                  DropdownMenuItem<String?>(value: null, child: Text('All Statuses')),
                  DropdownMenuItem<String?>(value: 'placed', child: Text('Placed')),
                  DropdownMenuItem<String?>(value: 'internship', child: Text('Internship')),
                  DropdownMenuItem<String?>(value: 'higherstudies', child: Text('Higher Studies')),
                  DropdownMenuItem<String?>(value: 'unplaced', child: Text('Unplaced')),
                ],
                onChanged: (value) => setState(() => selectedPlacementStatus = value),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              FilledButton.icon(
                onPressed: () => setState(() {
                  lastExport = controller.exportBatchData(
                    format: 'excel',
                    departmentId: selectedDepartmentId,
                    batch: selectedBatch,
                    classId: selectedClassId,
                    placementStatus: selectedPlacementStatus,
                  );
                }),
                icon: const Icon(Icons.table_chart_rounded),
                label: const Text('Export Excel'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => setState(() {
                  lastExport = controller.exportBatchData(
                    format: 'pdf',
                    departmentId: selectedDepartmentId,
                    batch: selectedBatch,
                    classId: selectedClassId,
                    placementStatus: selectedPlacementStatus,
                  );
                }),
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: const Text('Export PDF'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (lastExport != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.35),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${lastExport!.title} (${lastExport!.format})', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SelectableText(lastExport!.content),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfilePanel extends StatelessWidget {
  const _ProfilePanel({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final user = controller.currentUser!;
    final student = controller.currentStudentProfile;
    return SingleChildScrollView(
      child: Column(
        children: [
          _SectionCard(
            title: 'Account Profile',
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(radius: 26, child: Text(user.name.characters.first)),
                  title: Text(user.name),
                  subtitle: Text('${user.email} · ${user.role.label}'),
                ),
                if (student != null) ...[
                  const Divider(height: 30),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(label: 'Roll No', value: student.rollNo),
                      _InfoChip(label: 'Department', value: controller.departmentName(student.departmentId)),
                      _InfoChip(label: 'Class', value: controller.className(student.classId)),
                      _InfoChip(label: 'Batch', value: student.batch),
                      _InfoChip(label: 'Skills', value: student.skillset.join(', ')),
                      _InfoChip(label: 'Interest', value: student.preferredInterest.label),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _SectionCard(
                    title: 'Courses, Trainings & Internships',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Courses: ${student.courses.join(', ')}'),
                        const SizedBox(height: 8),
                        Text('Internships: ${student.internships.join(', ')}'),
                        const SizedBox(height: 8),
                        Text('Trainings: ${student.trainings.join(', ')}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SectionCard(
                    title: 'Placement Journey',
                    child: Column(
                      children: student.placementHistory.map((placement) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('${placement.organization} · ${placement.title}'),
                          subtitle: Text('${placement.stage.name.toUpperCase()} · ${placement.year}'),
                          trailing: Text(placement.packageLpa == 0 ? '-' : '${placement.packageLpa.toStringAsFixed(1)} LPA'),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SectionCard(
                    title: 'Opportunity History',
                    child: Column(
                      children: controller.currentStudentApplications.map((application) {
                        final opportunity = controller.allOpportunities.firstWhere((item) => item.id == application.opportunityId);
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('${opportunity.company} · ${opportunity.title}'),
                          subtitle: Text(_formatDate(application.appliedAt)),
                          trailing: Chip(label: Text(application.status.label)),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView({required this.controller});

  final AppController controller;

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final emailController = TextEditingController(text: 'admin@app.tnp');
  final passwordController = TextEditingController(text: 'admin123');
  String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF355CFF), Color(0xFF8F69FF), Color(0xFF39C8FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Placement portal for the full campus lifecycle.', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            const Text('Role-based access, student records, placement stats, job applications, exports, and profile tracking with an animated modern interface.'),
                            const SizedBox(height: 24),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: const [
                                Chip(label: Text('ADMIN')),
                                Chip(label: Text('PRINCIPAL')),
                                Chip(label: Text('TP OFFICER')),
                                Chip(label: Text('TP DEPARTMENTAL COORDINATOR')),
                                Chip(label: Text('STUDENT')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _SectionCard(
                        title: 'Login / Registration',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: emailController,
                              decoration: const InputDecoration(labelText: 'Email'),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(labelText: 'Password'),
                            ),
                            if (error != null) ...[
                              const SizedBox(height: 12),
                              Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                            ],
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: () {
                                try {
                                  widget.controller.login(emailController.text, passwordController.text);
                                } catch (err) {
                                  setState(() => error = '$err');
                                }
                              },
                              icon: const Icon(Icons.login_rounded),
                              label: const Text('Login'),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => _showRegistrationDialog(context, widget.controller),
                              child: const Text('New user? Register here'),
                            ),
                            const SizedBox(height: 18),
                            const Text('Sample credentials:'),
                            const SizedBox(height: 8),
                            const SelectableText(
                              'admin@app.tnp / admin123\nprincipal@app.tnp / principal123\nofficer@app.tnp / officer123\ncoordinator@app.tnp / coordinator123\nstudent@app.tnp / student123',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value, required this.subtitle, required this.icon});

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FaIcon(icon, color: Theme.of(context).colorScheme.primary),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.action});

  final String title;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
                if (action != null) action!,
              ],
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white24),
      ),
      child: child,
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
      ),
      child: Text('$label: $value'),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({required this.value, required this.items, required this.onChanged, required this.hint});

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(labelText: hint),
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}

Future<void> _showDepartmentDialog(BuildContext context, AppController controller, {Department? department}) async {
  final nameController = TextEditingController(text: department?.name ?? '');
  await _showFormDialog(
    context,
    title: department == null ? 'Add Department' : 'Edit Department',
    content: TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Department Name')),
    onSubmit: () => controller.upsertDepartment(id: department?.id, name: nameController.text),
  );
}

Future<void> _showClassDialog(BuildContext context, AppController controller, {ClassSection? classSection}) async {
  String? departmentId = classSection?.departmentId ?? controller.departments.firstOrNull?.id;
  final nameController = TextEditingController(text: classSection?.name ?? '');
  final batchController = TextEditingController(text: classSection?.batch ?? '2022-2026');
  await _showFormDialog(
    context,
    title: classSection == null ? 'Add Class' : 'Edit Class',
    content: StatefulBuilder(
      builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: departmentId,
              decoration: const InputDecoration(labelText: 'Department'),
              items: controller.departments
                  .map((item) => DropdownMenuItem(value: item.id, child: Text(item.name)))
                  .toList(),
              onChanged: (value) => setState(() => departmentId = value),
            ),
            const SizedBox(height: 12),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Class Name')),
            const SizedBox(height: 12),
            TextField(controller: batchController, decoration: const InputDecoration(labelText: 'Batch (e.g. 2022-2026)')),
          ],
        );
      },
    ),
    onSubmit: () => controller.upsertClass(
      id: classSection?.id,
      departmentId: departmentId ?? '',
      name: nameController.text,
      batch: batchController.text,
    ),
  );
}

Future<void> _showStudentDialog(BuildContext context, AppController controller, {StudentRecord? student}) async {
  final semesterScores = List<TextEditingController>.generate(
    8,
    (index) => TextEditingController(text: student?.semesterScores[index]?.toString() ?? ''),
  );
  String? departmentId = student?.departmentId ?? controller.departments.firstOrNull?.id;
  String? classId = student?.classId ?? controller.classesForDepartment(departmentId).firstOrNull?.id;
  StudentInterest interest = student?.preferredInterest ?? StudentInterest.job;
  final rollController = TextEditingController(text: student?.rollNo ?? '');
  final batchController = TextEditingController(text: student?.batch ?? '2022-2026');
  final nameController = TextEditingController(text: student?.name ?? '');
  final genderController = TextEditingController(text: student?.gender ?? '');
  final personalMobileController = TextEditingController(text: student?.personalMobile ?? '');
  final parentMobileController = TextEditingController(text: student?.parentMobile ?? '');
  final emailController = TextEditingController(text: student?.personalEmail ?? '');
  final linkedinController = TextEditingController(text: student?.linkedinProfile ?? '');
  final sscController = TextEditingController(text: student?.sscPercentage.toString() ?? '');
  final hscController = TextEditingController(text: student?.hscPercentage?.toString() ?? '');
  final diplomaController = TextEditingController(text: student?.diplomaPercentage?.toString() ?? '');
  final coursesController = TextEditingController(text: student?.courses.join(';') ?? '');
  final internshipsController = TextEditingController(text: student?.internships.join(';') ?? '');
  final trainingsController = TextEditingController(text: student?.trainings.join(';') ?? '');
  final skillsetController = TextEditingController(text: student?.skillset.join(';') ?? '');
  final photoController = TextEditingController(text: student?.photoUrl ?? '');

  await _showFormDialog(
    context,
    title: student == null ? 'Add Student' : 'Edit Student',
    content: StatefulBuilder(
      builder: (context, setState) {
        final availableClasses = controller.classesForDepartment(departmentId);
        classId ??= availableClasses.firstOrNull?.id;
        return SizedBox(
          width: 760,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: departmentId,
                        decoration: const InputDecoration(labelText: 'Department'),
                        items: controller.departments
                            .map((item) => DropdownMenuItem(value: item.id, child: Text(item.name)))
                            .toList(),
                        onChanged: (value) => setState(() {
                          departmentId = value;
                          classId = controller.classesForDepartment(value).firstOrNull?.id;
                        }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: classId,
                        decoration: const InputDecoration(labelText: 'Class'),
                        items: availableClasses
                            .map((item) => DropdownMenuItem(value: item.id, child: Text('${item.name} (${item.batch})')))
                            .toList(),
                        onChanged: (value) => setState(() => classId = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: batchController, decoration: const InputDecoration(labelText: 'Batch'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: rollController, decoration: const InputDecoration(labelText: 'Roll No'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name of the Student'))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: genderController, decoration: const InputDecoration(labelText: 'Gender'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: personalMobileController, decoration: const InputDecoration(labelText: 'Personal Mobile'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: parentMobileController, decoration: const InputDecoration(labelText: 'Parents Mobile'))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Personal Email ID'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: linkedinController, decoration: const InputDecoration(labelText: 'Linkedin Profile Link'))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: sscController, decoration: const InputDecoration(labelText: 'SSC %'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: hscController, decoration: const InputDecoration(labelText: 'HSC %'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: diplomaController, decoration: const InputDecoration(labelText: 'Diploma %'))),
                  ],
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  itemCount: semesterScores.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 3,
                  ),
                  itemBuilder: (context, index) {
                    return TextField(
                      controller: semesterScores[index],
                      decoration: InputDecoration(labelText: '${index + 1} Sem'),
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextField(controller: coursesController, decoration: const InputDecoration(labelText: 'Courses (semicolon separated)')),
                const SizedBox(height: 12),
                TextField(controller: internshipsController, decoration: const InputDecoration(labelText: 'Internships (semicolon separated)')),
                const SizedBox(height: 12),
                TextField(controller: trainingsController, decoration: const InputDecoration(labelText: 'Trainings (semicolon separated)')),
                const SizedBox(height: 12),
                TextField(controller: skillsetController, decoration: const InputDecoration(labelText: 'Skillset (semicolon separated)')),
                const SizedBox(height: 12),
                DropdownButtonFormField<StudentInterest>(
                  value: interest,
                  decoration: const InputDecoration(labelText: 'Preferred Interest'),
                  items: StudentInterest.values.map((item) => DropdownMenuItem(value: item, child: Text(item.label))).toList(),
                  onChanged: (value) => setState(() => interest = value ?? StudentInterest.job),
                ),
                const SizedBox(height: 12),
                TextField(controller: photoController, decoration: const InputDecoration(labelText: 'Photo URL / image path')),
              ],
            ),
          ),
        );
      },
    ),
    onSubmit: () {
      final parsedStudent = StudentRecord(
        id: student?.id ?? 'stu-${DateTime.now().microsecondsSinceEpoch}',
        rollNo: rollController.text,
        departmentId: departmentId ?? '',
        classId: classId ?? '',
        batch: batchController.text,
        name: nameController.text,
        gender: genderController.text,
        personalMobile: personalMobileController.text,
        parentMobile: parentMobileController.text,
        personalEmail: emailController.text,
        linkedinProfile: linkedinController.text,
        sscPercentage: double.parse(sscController.text),
        hscPercentage: _parseOptionalDouble(hscController.text),
        diplomaPercentage: _parseOptionalDouble(diplomaController.text),
        semesterScores: semesterScores.map((controller) => _parseOptionalDouble(controller.text)).toList(),
        courses: AppValidators.parseListField(coursesController.text),
        internships: AppValidators.parseListField(internshipsController.text),
        trainings: AppValidators.parseListField(trainingsController.text),
        skillset: AppValidators.parseListField(skillsetController.text),
        preferredInterest: interest,
        photoUrl: photoController.text,
        placementHistory: student?.placementHistory ?? const [],
      );
      controller.upsertStudent(parsedStudent);
    },
  );
}

Future<void> _showImportDialog(BuildContext context, AppController controller) async {
  final csvController = TextEditingController(text: controller.sampleCsvTemplate);
  await _showFormDialog(
    context,
    title: 'Bulk CSV Import',
    content: SizedBox(
      width: 760,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sample template'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.35),
            ),
            child: SelectableText(controller.sampleCsvTemplate),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: csvController,
            maxLines: 10,
            decoration: const InputDecoration(labelText: 'Paste CSV data'),
          ),
        ],
      ),
    ),
    onSubmit: () {
      final result = controller.importStudentsFromCsv(csvController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imported ${result.addedStudents.length} students. Errors: ${result.errors.length}')),
      );
      if (result.errors.isNotEmpty) {
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Import feedback'),
            content: SizedBox(
              width: 620,
              child: SingleChildScrollView(child: SelectableText(result.errors.join('\n'))),
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
          ),
        );
      }
    },
  );
}

Future<void> _showOpportunityDialog(BuildContext context, AppController controller, {Opportunity? opportunity}) async {
  final titleController = TextEditingController(text: opportunity?.title ?? '');
  final companyController = TextEditingController(text: opportunity?.company ?? '');
  final locationController = TextEditingController(text: opportunity?.location ?? '');
  final salaryController = TextEditingController(text: opportunity?.salaryPackage?.toString() ?? '');
  final stipendController = TextEditingController(text: opportunity?.stipend?.toString() ?? '');
  final deadlineController = TextEditingController(text: _formatDate(opportunity?.deadline ?? DateTime.now().add(const Duration(days: 14))));
  final eligibilityController = TextEditingController(text: opportunity?.eligibility ?? '');
  final descriptionController = TextEditingController(text: opportunity?.description ?? '');
  OpportunityType type = opportunity?.type ?? OpportunityType.job;
  OpportunityStatus status = opportunity?.status ?? OpportunityStatus.open;
  final selectedDepartments = {...?opportunity?.departmentIds};
  final batchesController = TextEditingController(text: opportunity?.batches.join(';') ?? '2022-2026');
  if (selectedDepartments.isEmpty && controller.currentUser?.departmentId != null && controller.currentUser?.role == UserRole.departmentCoordinator) {
    selectedDepartments.add(controller.currentUser!.departmentId!);
  }

  await _showFormDialog(
    context,
    title: opportunity == null ? 'Post Opportunity' : 'Edit Opportunity',
    content: StatefulBuilder(
      builder: (context, setState) {
        final allowedDepartments = controller.currentUser?.role == UserRole.departmentCoordinator
            ? controller.departments.where((item) => item.id == controller.currentUser?.departmentId).toList()
            : controller.departments;
        return SizedBox(
          width: 760,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: TextField(controller: companyController, decoration: const InputDecoration(labelText: 'Company'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title'))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<OpportunityType>(
                        value: type,
                        decoration: const InputDecoration(labelText: 'Type'),
                        items: OpportunityType.values.map((item) => DropdownMenuItem(value: item, child: Text(item.label))).toList(),
                        onChanged: (value) => setState(() => type = value ?? OpportunityType.job),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<OpportunityStatus>(
                        value: status,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: OpportunityStatus.values.map((item) => DropdownMenuItem(value: item, child: Text(item.label))).toList(),
                        onChanged: (value) => setState(() => status = value ?? OpportunityStatus.open),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Location'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: salaryController, decoration: const InputDecoration(labelText: 'Salary Package (LPA)'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: stipendController, decoration: const InputDecoration(labelText: 'Stipend'))),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(controller: deadlineController, decoration: const InputDecoration(labelText: 'Deadline (YYYY-MM-DD)')),
                const SizedBox(height: 12),
                TextField(controller: eligibilityController, maxLines: 2, decoration: const InputDecoration(labelText: 'Eligibility')), 
                const SizedBox(height: 12),
                TextField(controller: descriptionController, maxLines: 3, decoration: const InputDecoration(labelText: 'Description')), 
                const SizedBox(height: 12),
                TextField(controller: batchesController, decoration: const InputDecoration(labelText: 'Batches (semicolon separated)')),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Departments', style: Theme.of(context).textTheme.titleMedium),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allowedDepartments.map((department) {
                    final selected = selectedDepartments.contains(department.id);
                    return FilterChip(
                      label: Text(department.name),
                      selected: selected,
                      onSelected: (value) {
                        setState(() {
                          if (value) {
                            selectedDepartments.add(department.id);
                          } else {
                            selectedDepartments.remove(department.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    ),
    onSubmit: () {
      controller.upsertOpportunity(
        Opportunity(
          id: opportunity?.id ?? 'opp-${DateTime.now().microsecondsSinceEpoch}',
          title: titleController.text,
          company: companyController.text,
          type: type,
          status: status,
          location: locationController.text,
          salaryPackage: _parseOptionalDouble(salaryController.text),
          stipend: _parseOptionalDouble(stipendController.text),
          deadline: DateTime.parse(deadlineController.text),
          eligibility: eligibilityController.text,
          description: descriptionController.text,
          departmentIds: selectedDepartments.toList(),
          batches: AppValidators.parseListField(batchesController.text),
          postedByRole: controller.currentUser!.role,
          postedByName: controller.currentUser!.name,
        ),
      );
    },
  );
}

Future<void> _showApplyDialog(BuildContext context, AppController controller, Opportunity opportunity) async {
  final noteController = TextEditingController(text: 'Interested in applying for this role.');
  await _showFormDialog(
    context,
    title: 'Apply to ${opportunity.company}',
    content: TextField(controller: noteController, maxLines: 4, decoration: const InputDecoration(labelText: 'Application note')),
    onSubmit: () => controller.applyToOpportunity(opportunityId: opportunity.id, note: noteController.text),
  );
}

Future<void> _showRegistrationDialog(BuildContext context, AppController controller) async {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  UserRole role = UserRole.student;
  String? departmentId = controller.departments.firstOrNull?.id;
  await _showFormDialog(
    context,
    title: 'Register User',
    content: StatefulBuilder(
      builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 12),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 12),
            DropdownButtonFormField<UserRole>(
              value: role,
              decoration: const InputDecoration(labelText: 'Role'),
              items: UserRole.values.map((item) => DropdownMenuItem(value: item, child: Text(item.label))).toList(),
              onChanged: (value) => setState(() => role = value ?? UserRole.student),
            ),
            if (role == UserRole.departmentCoordinator || role == UserRole.student) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: departmentId,
                decoration: const InputDecoration(labelText: 'Department'),
                items: controller.departments.map((item) => DropdownMenuItem(value: item.id, child: Text(item.name))).toList(),
                onChanged: (value) => setState(() => departmentId = value),
              ),
            ],
          ],
        );
      },
    ),
    onSubmit: () => controller.register(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
      role: role,
      departmentId: departmentId,
    ),
  );
}

Future<void> _showFormDialog(
  BuildContext context, {
  required String title,
  required Widget content,
  required VoidCallback onSubmit,
}) async {
  String? error;
  await showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                content,
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                try {
                  onSubmit();
                  Navigator.pop(context);
                } catch (err) {
                  setState(() => error = '$err');
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ),
  );
}

Future<void> _confirmDelete(
  BuildContext context, {
  required String title,
  required String message,
  required VoidCallback onConfirm,
}) async {
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            try {
              onConfirm();
              Navigator.pop(context);
            } catch (err) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$err')));
            }
          },
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

double? _parseOptionalDouble(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  return double.parse(trimmed);
}

extension _FirstOrNullExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
