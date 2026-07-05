import { IPositionRepository, ICandidateRepository } from '../domain/repositories/IPositionRepository';

export interface IUnitOfWorkContext {
  positions: IPositionRepository;
  candidates: ICandidateRepository;
}

export interface IUnitOfWork {
  execute<T>(work: (context: IUnitOfWorkContext) => Promise<T>): Promise<T>;
}
