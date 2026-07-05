import { PositionEntity } from '../entities/PositionEntity';

// Specification pattern for queries
export interface ISpecification<T> {
  isSatisfiedBy(candidate: T): boolean;
  toPrismaQuery?(): any; // Infrastructure leak gracefully allowed for ORM integration if needed, or kept pure.
}

export interface IPositionRepository {
  findById(id: string): Promise<PositionEntity | null>;
  save(position: PositionEntity): Promise<void>;
  find(spec: ISpecification<PositionEntity>): Promise<PositionEntity[]>;
}

export interface ICandidateRepository {
  // Methods for candidate
}
