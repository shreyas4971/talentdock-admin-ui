import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function main() {
  console.log('Seeding database...');

  // 1. Create the base workspace (Required by schema)
  const workspace = await prisma.organization.upsert({
    where: { id: 'talentdock-workspace' },
    update: {},
    create: {
      id: 'talentdock-workspace',
      name: 'TalentDock Personal Workspace',
    },
  });
  console.log(`✅ Base workspace configured.`);

  // 2. Create an admin user
  const admin = await prisma.user.upsert({
    where: { email: 'admin@talentos.local' },
    update: {},
    create: {
      email: 'admin@talentdock.local',
      passwordHash: 'admin123', // Demo password
      role: 'ADMIN',
      organizationId: workspace.id,
    },
  });
  console.log(`✅ Admin User created: ${admin.email}`);

  // 3. Create a sample position
  const position = await prisma.position.create({
    data: {
      title: 'Senior Flutter Developer',
      department: 'Engineering',
      location: 'Remote',
      description: 'We are looking for a rockstar Flutter developer to build beautiful UIs.',
      status: 'PUBLISHED',
      organizationId: workspace.id,
    },
  });
  console.log(`✅ Sample Position created: ${position.title}`);

  // 4. Create a sample candidate & application
  const candidate = await prisma.candidate.create({
    data: {
      firstName: 'Jane',
      lastName: 'Doe',
      email: 'jane.doe@example.com',
      phone: '555-0199',
      organizationId: workspace.id,
    },
  });
  
  await prisma.candidateApplication.create({
    data: {
      referenceId: 'REC-DEMO-001',
      candidateId: candidate.id,
      positionId: position.id,
      status: 'APPLIED',
      experienceYears: 4,
    }
  });
  console.log(`✅ Sample Candidate applied: ${candidate.firstName} ${candidate.lastName}`);

  console.log('Database seeding complete!');
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });
