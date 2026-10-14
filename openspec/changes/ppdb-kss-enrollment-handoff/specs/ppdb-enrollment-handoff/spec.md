## Purpose
Defines how PPDB hands an accepted applicant over to KSS, and how staff can see and recover the outcome of each handoff.

## ADDED Requirements

### Requirement: Accepting a formulir starts a KSS handoff
The PPDB system SHALL create a handoff record in state `PENDING` for a formulir in the same operation that sets the formulir to `accepted`, and SHALL then attempt to send the enrollment to KSS.

#### Scenario: Accepted formulir is sent to KSS
- **WHEN** staff accept a reviewed formulir with a level and KSS accepts the enrollment
- **THEN** the formulir is `accepted`
- **AND** its handoff is `SENT` with the KSS student id and parent id recorded

#### Scenario: Acceptance does not depend on KSS being available
- **WHEN** staff accept a reviewed formulir and KSS cannot be reached or rejects the enrollment
- **THEN** the formulir is still `accepted`
- **AND** its handoff is `FAILED` with the failure reason recorded
- **AND** the accept response tells staff that the KSS handoff failed and why

### Requirement: Handoff sends only the data KSS needs
The enrollment sent to KSS MUST contain only: a stable source identifier for the formulir, the academic year name, the accepted level, the student's full name and gender, and the parent account's full name, email, phone and address.

#### Scenario: Health and family details stay in PPDB
- **WHEN** an enrollment is sent for a formulir that has health history, allergies and second-parent details
- **THEN** none of those fields are included in the request to KSS

#### Scenario: Unmappable gender fails before sending
- **WHEN** the formulir gender is neither `Laki-laki` nor `Perempuan`
- **THEN** the handoff becomes `FAILED` with a reason naming the invalid gender
- **AND** no request is sent to KSS

### Requirement: Staff can see and retry handoffs
The PPDB system SHALL expose each accepted formulir's handoff status, attempt count and last failure reason to PPDB staff roles, and SHALL let them retry a handoff that is not `SENT`.

#### Scenario: Staff retry a failed handoff
- **WHEN** a PPDB staff user retries a `FAILED` handoff after the cause was fixed and KSS accepts the enrollment
- **THEN** the handoff becomes `SENT` and the attempt count increases

#### Scenario: Sent handoffs are not resent
- **WHEN** a PPDB staff user retries a handoff that is already `SENT`
- **THEN** the system rejects the retry with a conflict error and does not contact KSS

#### Scenario: Parents cannot see or trigger handoffs
- **WHEN** a parent requests the retry endpoint
- **THEN** the system rejects the request as forbidden

### Requirement: Retries are safe
The PPDB system MUST send the same source identifier on every attempt for a formulir, so that KSS can treat repeated attempts as the same enrollment.

#### Scenario: Retry after a lost response
- **WHEN** KSS created the enrollment but PPDB did not receive the response, and staff retry
- **THEN** KSS returns the existing enrollment and the handoff becomes `SENT` with the same KSS ids
