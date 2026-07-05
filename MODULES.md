# TalentOS Ecosystem Modules

The long-term vision of TalentOS is to serve as a unified, modular HR platform. Development will proceed incrementally across these domains based strictly on validated business needs.

### 1. Recruitment (Released: v1.0.0)
- **Purpose**: Manage job postings, accept candidate applications, and track candidates through the hiring pipeline.
- **Current Status**: MVP Released.
- **Planned Dependencies**: None.
- **Future Release Target**: Ongoing maintenance.

### 2. Employees
- **Purpose**: Core directory of all active and past employees. Acts as the master record for identities across all other modules.
- **Current Status**: Planning / RFC phase.
- **Planned Dependencies**: Recruitment (for seamless Candidate -> Employee onboarding transitions).
- **Future Release Target**: v2.0

### 3. Attendance
- **Purpose**: Track employee working hours, shifts, and remote availability.
- **Current Status**: Backlog.
- **Planned Dependencies**: Employees.
- **Future Release Target**: TBD

### 4. Leave
- **Purpose**: Manage time-off requests, accruals, holidays, and approvals.
- **Current Status**: Backlog.
- **Planned Dependencies**: Employees, Attendance.
- **Future Release Target**: TBD

### 5. Payroll
- **Purpose**: Salary calculations, tax deductions, bonuses, and payslip generation.
- **Current Status**: Backlog.
- **Planned Dependencies**: Employees, Attendance, Leave.
- **Future Release Target**: TBD

### 6. Performance
- **Purpose**: OKRs, KPIs, 360-degree feedback, and annual performance reviews.
- **Current Status**: Backlog.
- **Planned Dependencies**: Employees.
- **Future Release Target**: TBD

### 7. Assets
- **Purpose**: Tracking company-issued hardware and software licenses (laptops, monitors, keys).
- **Current Status**: Backlog.
- **Planned Dependencies**: Employees.
- **Future Release Target**: TBD

### 8. Documents
- **Purpose**: Secure vault for employee contracts, NDAs, policies, and compliance forms.
- **Current Status**: Backlog.
- **Planned Dependencies**: Employees.
- **Future Release Target**: TBD

### 9. Training
- **Purpose**: Internal LMS for onboarding workflows, compliance training, and skill development.
- **Current Status**: Backlog.
- **Planned Dependencies**: Employees, Performance.
- **Future Release Target**: TBD

### 10. Settings
- **Purpose**: Global platform configuration, Role-Based Access Control (RBAC), API keys, and audit logs.
- **Current Status**: Partial implementation (basic auth).
- **Planned Dependencies**: None.
- **Future Release Target**: Incremental alongside all modules.
