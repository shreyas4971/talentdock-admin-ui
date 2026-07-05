import { Router } from 'express';
import { PrismaClient } from '@prisma/client';
import multer from 'multer';
import { Storage } from '@google-cloud/storage';
import { v4 as uuidv4 } from 'uuid';
import path from 'path';
import logger from '../../utils/logger';

const router = Router();
const prisma = new PrismaClient();
const storage = new Storage();
const bucketName = process.env.GCS_BUCKET_NAME || 'talentos-mvp-bucket';

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB limit
  fileFilter: (req, file, cb) => {
    const allowedTypes = [
      'application/pdf', 
      'application/msword', 
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
    ];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type. Only PDF and DOCX are allowed.'));
    }
  }
});

router.post('/', upload.single('resume'), async (req: any, res: any) => {
  try {
    const { 
      positionId, firstName, lastName, email, phone, experienceYears, 
      city, country, currentCompany, currentRole, expectedSalary, 
      noticePeriod, linkedin, portfolio 
    } = req.body;
    const file = req.file;
    if (!file) {
      return res.status(400).json({ success: false, message: 'Resume is required' });
    }

    const orgId = req.headers['x-org-id'] || 'default-org-id';

    const position = await prisma.position.findUnique({ where: { id: positionId } });
    if (!position || position.status !== 'PUBLISHED') {
      return res.status(404).json({ success: false, message: 'Position not found or not open' });
    }

    const count = await prisma.candidateApplication.count();
    const referenceId = `REC-${new Date().getFullYear()}-${String(count + 1).padStart(6, '0')}`;

    let candidate = await prisma.candidate.findFirst({
      where: { email, organizationId: orgId }
    });

    if (!candidate) {
      candidate = await prisma.candidate.create({
        data: { organizationId: orgId, firstName, lastName, email, phone, linkedin, portfolio }
      });
    }

    const application = await prisma.candidateApplication.create({
      data: {
        referenceId,
        candidateId: candidate.id,
        positionId,
        experienceYears: experienceYears ? parseInt(experienceYears) : null,
        city,
        country,
        currentCompany,
        currentRole,
        expectedSalary,
        noticePeriod
      }
    });

    const fileUuid = uuidv4();
    const ext = path.extname(file.originalname);
    const storedFilename = `Resume_${fileUuid}${ext}`;
    const gcsPath = `Recruitment/Positions/${positionId}/${candidate.id}/${storedFilename}`;
    
    try {
      const bucket = storage.bucket(bucketName);
      const blob = bucket.file(gcsPath);
      await blob.save(file.buffer, { contentType: file.mimetype });
    } catch (gcsError: any) {
      logger.error('GCS Upload mocked for local dev. Error: ' + gcsError.message);
    }

    await prisma.candidateDocument.create({
      data: {
        applicationId: application.id,
        logicalName: file.originalname,
        mimeType: file.mimetype,
        sizeBytes: file.size,
        storageKey: gcsPath
      }
    });

    await prisma.analyticsEvent.create({
      data: { organizationId: orgId, eventName: 'APPLICATION_SUBMITTED' }
    });

    res.json({ success: true, data: { referenceId } });
  } catch (error: any) {
    logger.error('Application submission failed: ' + error.message, { stack: error.stack });
    res.status(500).json({ success: false, message: error.message });
  }
});

export default router;
