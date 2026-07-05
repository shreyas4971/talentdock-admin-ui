import { PositionStatus } from 'shared_contracts';
import { BusinessRuleViolation } from '../errors/DomainErrors';

export class PositionEntity {
  constructor(
    public id: string,
    public organizationId: string,
    public name: string,
    public status: PositionStatus
  ) {}

  public publish(): void {
    if (this.status !== PositionStatus.DRAFT) {
      throw new BusinessRuleViolation('Only DRAFT positions can be published');
    }
    this.status = PositionStatus.PUBLISHED;
  }

  public open(): void {
    if (this.status !== PositionStatus.PUBLISHED && this.status !== PositionStatus.PAUSED) {
      throw new BusinessRuleViolation('Only PUBLISHED or PAUSED positions can be opened');
    }
    this.status = PositionStatus.OPEN;
  }

  public archive(): void {
    if (this.status === PositionStatus.ARCHIVED) {
      throw new BusinessRuleViolation('Position is already archived');
    }
    this.status = PositionStatus.ARCHIVED;
  }
}
