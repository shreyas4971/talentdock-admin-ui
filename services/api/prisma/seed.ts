import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function main() {
  console.log('Seeding database...');

  // 1. Ensure a default organization exists
  const org = await prisma.organization.upsert({
    where: { id: 'default-org-id' },
    update: {},
    create: {
      id: 'default-org-id',
      name: 'My Personal Workspace',
    },
  });
  console.log(`✅ Organization created: ${org.name}`);

  // 2. Create an admin user
  const admin = await prisma.user.upsert({
    where: { email: 'admin@talentos.local' },
    update: {},
    create: {
      email: 'admin@talentos.local',
      passwordHash: 'admin123', // Demo password
      role: 'ADMIN',
      organizationId: org.id,
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
      organizationId: org.id,
    },
  });
  console.log(`✅ Sample Position created: ${position.title}`);

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
