## Purpose
Lets KSS administrators decide which KSS class receives applicants accepted in PPDB at a given level, per academic year.

## ADDED Requirements

### Requirement: Superadmin manages PPDB class mappings
The KSS system SHALL allow an authenticated superadmin to list, create, update and delete mappings of (academic year, PPDB level) to a KSS class.

#### Scenario: Superadmin creates a mapping
- **WHEN** a superadmin maps level `KSS A` in academic year `2026/2027` to an existing class of that year
- **THEN** the mapping is saved and listed with the academic year, level and class name

#### Scenario: Non-superadmin is rejected
- **WHEN** a user without the `SUPERADMIN` role calls any mapping endpoint
- **THEN** the system responds 403

### Requirement: Mappings are unique and consistent
The KSS system MUST keep at most one mapping per academic year and level, and MUST only map to a class that belongs to the same academic year.

#### Scenario: Duplicate level in the same year
- **WHEN** a superadmin creates a second mapping for a year and level that is already mapped
- **THEN** the system responds 409

#### Scenario: Class from another year
- **WHEN** a superadmin maps a level to a class whose academic year differs from the mapping's year
- **THEN** the system responds 422

#### Scenario: Level matching ignores case and surrounding spaces
- **WHEN** a mapping exists for `KSS A` and an enrollment arrives with level ` kss a `
- **THEN** intake resolves the same class

### Requirement: Mapping changes do not move enrolled students
The KSS system SHALL apply a changed or deleted mapping only to enrollments received afterwards.

#### Scenario: Mapping changed after intake
- **WHEN** a superadmin points a mapping to a different class after students were enrolled through it
- **THEN** the already enrolled students stay in their original class
