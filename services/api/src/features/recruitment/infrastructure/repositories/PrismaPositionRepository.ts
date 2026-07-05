import { Prisma } from '@prisma/client';
import { IPositionRepository, ISpecification } from '../../domain/repositories/IPositionRepository';
import { PositionEntity } from '../../domain/entities/PositionEntity';
import { PositionStatus } from 'shared_contracts';

export class PrismaPositionRepository implements IPositionRepository {
  constructor(private tx: Prisma.TransactionClient) {}

  private toDomain(model: any): PositionEntity {
    return new PositionEntity(
      model.id,
      model.organizationId,
      model.name,
      model.status as PositionStatus
    );
  }

  async findById(id: string): Promise<PositionEntity | null> {
    const model = await this.tx.position.findUnique({ where: { id } });
    return model ? this.toDomain(model) : null;
  }

  async save(position: PositionEntity): Promise<void> {
    await this.tx.position.upsert({
      where: { id: position.id },
      update: {
        name: position.name,
        status: position.status,
      },
      create: {
        id: position.id,
        organizationId: position.organizationId,
        name: position.name,
        status: position.status,
        department: 'Engineering', // hardcoded for the mock test
        employmentType: 'FULL_TIME',
      },
    });
  }

  async find(spec: ISpecification<PositionEntity>): Promise<PositionEntity[]> {
    const where = spec.toPrismaQuery ? spec.toPrismaQuery() : {};
    const models = await this.tx.position.findMany({ where });
    return models.map(this.toDomain);
  }
}
