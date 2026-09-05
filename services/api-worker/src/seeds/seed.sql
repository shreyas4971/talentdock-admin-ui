-- TalentDock V1 D1 Seed Data (LOCAL DEVELOPMENT ONLY)

-- 1. Initial Development Admin User
-- Password (dev only): talentdock-temp
-- Stored Hash Format: pbkdf2:sha256:100000:<salt_hex>:<hash_hex>
INSERT OR REPLACE INTO users (id, email, password_hash, name, role, created_at, updated_at)
VALUES (
  'usr-admin-001',
  'admin@talentdock.local',
  'pbkdf2:sha256:100000:0123456789abcdeffedcba9876543210:db95ee9c5a489f08d3b0d9939825de004d8faafb700a37d729c932774aba04b9',
  'TalentDock Administrator',
  'ADMIN',
  datetime('now'),
  datetime('now')
);

-- 2. Initial Sample Positions (Matching Flutter mock positions for parity)
INSERT OR REPLACE INTO positions (
  id, title, department, location, employment_type, experience, status, is_pinned, short_description, description, responsibilities, requirements, benefits, created_at, updated_at
) VALUES 
(
  'pos-001',
  'Flutter Developer',
  'Engineering',
  'Remote',
  'Full-time',
  '3-5 Years',
  'PUBLISHED',
  1,
  'Join our core mobile team to build fast, beautiful, and fluid cross-platform applications.',
  'We are looking for an experienced Flutter Developer to join our core engineering team. You will be responsible for architecting and building our next-generation mobile applications for both iOS and Android.',
  '["Design and build advanced applications for the Flutter platform.","Collaborate with cross-functional teams to define, design, and ship new features.","Work on bug fixing and improving application performance.","Continuously discover, evaluate, and implement new technologies to maximize development efficiency."]',
  '["Proven working experience in software development.","Working experience in mobile development (Flutter/Dart).","Experience with third-party libraries and APIs.","Solid understanding of the full mobile development life cycle."]',
  '["Competitive salary and equity.","Health, dental, and vision insurance.","Flexible working hours and remote options.","Generous learning and development budget."]',
  datetime('now', '-7 days'),
  datetime('now')
),
(
  'pos-002',
  'Embedded Engineer',
  'Hardware',
  'San Francisco, CA',
  'Full-time',
  '2-4 Years',
  'PUBLISHED',
  0,
  'Develop low-level firmware and bring up new hardware platforms for our IoT devices.',
  'As an Embedded Engineer, you will develop firmware for our suite of connected devices. You will be involved in the full product lifecycle, from initial hardware bring-up and debugging to writing production-quality C/C++ code for RTOS environments.',
  '["Design, develop, code, test, and debug system software.","Review code and design.","Analyze and enhance efficiency, stability and scalability of system resources.","Integrate and validate new product designs."]',
  '["Proven experience in embedded systems design with preemptive, multitasking real-time operating systems.","Familiarity with software configuration management tools, defect tracking tools, and peer review.","Excellent knowledge of OS coding techniques, IP protocols, interfaces and hardware subsystems.","Adequate knowledge of reading schematics and data sheets for components."]',
  '["Competitive salary.","Comprehensive health benefits.","On-site hardware lab access.","Relocation assistance if required."]',
  datetime('now', '-5 days'),
  datetime('now')
),
(
  'pos-003',
  'Product Designer',
  'Design',
  'Remote',
  'Contract',
  '5+ Years',
  'PUBLISHED',
  0,
  'Shape the user experience and visual design of our flagship software products.',
  'We are seeking a talented and experienced Product Designer to lead the design of our core software products. You will be responsible for creating intuitive, elegant, and highly functional user interfaces that solve complex problems for our users.',
  '["Create wireframes, prototypes, and high-fidelity mockups.","Conduct user research and usability testing.","Collaborate closely with engineering to ensure high-quality implementation.","Maintain and evolve our design system."]',
  '["Strong portfolio demonstrating UI/UX design skills.","Proficiency in Figma and prototyping tools.","Experience working in agile software development environments.","Excellent communication and presentation skills."]',
  '["Flexible contract terms.","Opportunity to work on high-impact products.","Remote-first culture."]',
  datetime('now', '-3 days'),
  datetime('now')
),
(
  'pos-004',
  'Backend Developer',
  'Engineering',
  'Remote',
  'Full-time',
  '3-5 Years',
  'PUBLISHED',
  1,
  'Build scalable microservices and edge compute backends.',
  'We are looking for a skilled Backend Developer to engineer robust APIs and cloud workflows.',
  '["Build and maintain high-performance API services.","Design efficient relational database schemas.","Ensure security and data integrity across systems."]',
  '["Strong experience in TypeScript, Node.js or edge workers.","Experience with SQL and relational databases.","Understanding of distributed systems and caching."]',
  '["Competitive salary.","Remote work freedom.","Health and retirement benefits."]',
  datetime('now', '-10 days'),
  datetime('now')
),
(
  'pos-005',
  'QA Engineer',
  'Engineering',
  'London',
  'Full-time',
  '1-3 Years',
  'PUBLISHED',
  0,
  'Ensure exceptional quality across web and mobile releases.',
  'Join our QA team to craft automated test suites and test end-to-end recruitment workflows.',
  '["Develop and execute automated test scripts.","Perform manual cross-browser testing.","Identify and document defects."]',
  '["Experience in software testing methodologies.","Familiarity with automated testing frameworks.","Strong attention to detail."]',
  '["Comprehensive benefits.","Modern London office space and flexible options."]',
  datetime('now', '-2 days'),
  datetime('now')
),
(
  'pos-006',
  'HR Manager',
  'HR',
  'Chicago',
  'Full-time',
  '5+ Years',
  'DRAFT',
  0,
  'Lead people operations and recruitment strategy.',
  'We are looking for an HR Manager to oversee talent acquisition, company culture, and employee satisfaction.',
  '["Manage full-cycle recruiting processes.","Develop HR policies and employee handbooks."]',
  '["5+ years HR and recruitment experience.","Strong communication skills."]',
  '["Full health coverage.","401(k) matching."]',
  datetime('now', '-1 day'),
  datetime('now')
);
