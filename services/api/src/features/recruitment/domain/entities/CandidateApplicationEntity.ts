import { ApplicationStatus } from 'shared_contracts';
import { BusinessRuleViolation } from '../errors/DomainErrors';

export class CandidateApplicationEntity {
  constructor(
    public id: string,
    public positionId: string,
    public candidateId: string,
    public status: ApplicationStatus
  ) {}

  public canTransitionTo(newStatus: ApplicationStatus): boolean {
    const validTransitions: Record<ApplicationStatus, ApplicationStatus[]> = {
      [ApplicationStatus.APPLIED]: [ApplicationStatus.UNDER_REVIEW, ApplicationStatus.REJECTED],
      [ApplicationStatus.UNDER_REVIEW]: [ApplicationStatus.TECHNICAL_REVIEW, ApplicationStatus.HR_REVIEW, ApplicationStatus.REJECTED],
      [ApplicationStatus.TECHNICAL_REVIEW]: [ApplicationStatus.HR_REVIEW, ApplicationStatus.REJECTED],
      [ApplicationStatus.HR_REVIEW]: [ApplicationStatus.OFFER, ApplicationStatus.REJECTED],
      [ApplicationStatus.OFFER]: [ApplicationStatus.ACCEPTED, ApplicationStatus.REJECTED],
      [ApplicationStatus.ACCEPTED]: [ApplicationStatus.ARCHIVED],
      [ApplicationStatus.REJECTED]: [ApplicationStatus.ARCHIVED],
      [ApplicationStatus.ARCHIVED]: [],
    };

    return validTransitions[this.status]?.includes(newStatus) ?? false;
  }

  public changeStatus(newStatus: ApplicationStatus): void {
    if (!this.canTransitionTo(newStatus)) {
      throw new BusinessRuleViolation(
        `Cannot transition application from ${this.status} to ${newStatus}`
      );
    }
    this.status = newStatus;
  }
}
