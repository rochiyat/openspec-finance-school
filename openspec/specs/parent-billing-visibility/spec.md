## Purpose
This capability allows parents to view and monitor their linked children's financial records (billings, installments, and payments) through a dedicated dashboard in the application.

## Requirements

### Requirement: Parents can view a consolidated dashboard of financial records
The system SHALL provide a frontend interface allowing parents to view the billing, installment, and payment records of their linked children.

#### Scenario: Active parent views financial dashboard
- **WHEN** an authenticated `PARENT` user accesses the financial dashboard
- **THEN** the system displays the billing and payment state for all children linked to that parent via `student-parent-mapping`
