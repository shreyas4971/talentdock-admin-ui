import { PrismaClient, Prisma } from '@prisma/client';
import { IUnitOfWork, IUnitOfWorkContext } from './IUnitOfWork';
import { PrismaPositionRepository } from '../repositories/PrismaPositionRepository';
import { ICandidateRepository } from '../../domain/repositories/IPositionRepository';

const prisma = new PrismaClient();

export class PrismaUnitOfWork implements IUnitOfWork {
  async execute<T>(work: (context: IUnitOfWorkContext) => Promise<T>): Promise<T> {
    return prisma.$transaction(async (tx) => {
      const context: IUnitOfWorkContext = {
        positions: new PrismaPositionRepository(tx),
        candidates: {} as ICandidateRepository, // Mock for now until implemented
      };
      
      const result = await work(context);
      
      // Events can be dispatched here post-commit or by the caller after execution succeeds
      
      return result;
    });
  }
}
