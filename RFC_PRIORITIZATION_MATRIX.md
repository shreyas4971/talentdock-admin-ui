# RFC Prioritization Matrix

Every proposed RFC must be scored across the following 5 dimensions. The total weighted score dictates the priority ranking in the backlog.

### Scoring Scale (1 to 5)
- **1** = Minimal / Low
- **3** = Moderate / Medium
- **5** = Critical / High

### Dimensions

1. **User Impact (Weight: x3)**
   - *How many users does this affect? Does it solve a daily frustration or a rare edge case?*
2. **Business Value (Weight: x3)**
   - *Does this directly improve Time-to-Hire, Candidate Experience, or reduce manual operational overhead?*
3. **Frequency of Requests (Weight: x2)**
   - *How often has this issue been reported in the Feedback Dashboard?*
4. **Strategic Alignment (Weight: x2)**
   - *Does this align with the TalentOS Ecosystem vision, or is it a random feature request?*
5. **Development Effort (Weight: x-2) [INVERSE]**
   - *High effort (5) reduces the score (-10). Low effort (1) minimizes the penalty (-2).*

### Total Score Calculation
`Score = (User Impact * 3) + (Business Value * 3) + (Frequency * 2) + (Alignment * 2) - (Effort * 2)`

### Prioritization Bands
- **> 35**: Immediate Priority (Schedule for next minor release).
- **20 - 34**: Backlog (Schedule when capacity allows).
- **< 20**: Defer / Reject (Not currently aligned with business needs).
