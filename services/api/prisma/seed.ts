import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function main() {
  console.log('Seeding TalentDock database...');

  // 1. Create the base workspace (Required by schema, hidden from UI)
  const workspace = await prisma.organization.upsert({
    where: { id: 'talentdock-workspace' },
    update: {},
    create: {
      id: 'talentdock-workspace',
      name: 'TalentDock Personal Workspace',
    },
  });

  // 2. Create an admin user (Credentials from ENV or default temporary)
  const adminPassword = process.env.ADMIN_PASSWORD || 'talentdock-temp';
  const admin = await prisma.user.upsert({
    where: { email: 'admin@talentdock.local' },
    update: { passwordHash: adminPassword },
    create: {
      email: 'admin@talentdock.local',
      passwordHash: adminPassword, // Demo password
      role: 'ADMIN',
      organizationId: workspace.id,
    },
  });
  console.log(`✅ Admin User created: ${admin.email}`);
  if (adminPassword === 'talentdock-temp') {
    console.log(`⚠️  Using default temporary password: talentdock-temp. Please change it after login.`);
  }

  // 3. Create sample positions
  const pos1 = await prisma.position.create({
    data: {
      title: 'Senior Flutter Developer',
      department: 'Engineering',
      location: 'Remote',
      description: 'We are looking for a rockstar Flutter developer to build beautiful UIs.',
      status: 'PUBLISHED',
      organizationId: workspace.id,
    },
  });
  const pos2 = await prisma.position.create({
    data: {
      title: 'Product Designer',
      department: 'Design',
      location: 'New York (Hybrid)',
      description: 'Design the future of recruitment software with us.',
      status: 'PUBLISHED',
      organizationId: workspace.id,
    },
  });
  console.log(`✅ Sample Positions created: ${pos1.title}, ${pos2.title}`);

  // 4. Create sample candidates & applications
  const cand1 = await prisma.candidate.create({
    data: { firstName: 'Jane', lastName: 'Doe', email: 'jane.doe@example.com', phone: '555-0199', organizationId: workspace.id }
  });
  const cand2 = await prisma.candidate.create({
    data: { firstName: 'John', lastName: 'Smith', email: 'john.smith@example.com', phone: '555-0200', organizationId: workspace.id }
  });
  const cand3 = await prisma.candidate.create({
    data: { firstName: 'Alice', lastName: 'Johnson', email: 'alice.j@example.com', phone: '555-0201', organizationId: workspace.id }
  });
  
  await prisma.candidateApplication.create({
    data: { referenceId: 'REC-DEMO-001', candidateId: cand1.id, positionId: pos1.id, status: 'INTERVIEW', experienceYears: 5 }
  });
  await prisma.candidateApplication.create({
    data: { referenceId: 'REC-DEMO-002', candidateId: cand2.id, positionId: pos1.id, status: 'APPLIED', experienceYears: 2 }
  });
  await prisma.candidateApplication.create({
    data: { referenceId: 'REC-DEMO-003', candidateId: cand3.id, positionId: pos2.id, status: 'REVIEWING', experienceYears: 7 }
  });
  console.log(`✅ 3 Sample Candidates applied.`);

  // 5. Analytics/Dashboard data
  await prisma.analyticsEvent.create({ data: { eventName: 'position_created', organizationId: workspace.id }});
  await prisma.analyticsEvent.create({ data: { eventName: 'applications_submitted', organizationId: workspace.id }});
  await prisma.analyticsEvent.create({ data: { eventName: 'status_changes', organizationId: workspace.id }});

  console.log('Database seeding complete!');
}

main()
  .then(async () => { await prisma.$disconnect(); })
  .catch(async (e) => { console.error(e); await prisma.$disconnect(); process.exit(1); });
