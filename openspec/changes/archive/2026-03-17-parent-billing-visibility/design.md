## Context

Parents currently lack a direct way to view their children's financial obligations (billings/installments) and payment history. The system already has functional modules for billing, installments, and payment entries, but these are guarded and accessible only by users with `FINANCE` or `SUPERADMIN` roles. We need to expose read-only variations of these APIs to allow authenticated users with the `PARENT` role to fetch records if they are explicitly linked to the student in question. We already have a `student-parent-mapping` capability to rely on for authorization.

## Goals / Non-Goals

**Goals:**
- Provide read-only access to billing records, installment plans, and payment histories for parents.
- Secure these APIs so parents can only query data for students they are linked to.
- Build a parent-facing frontend view to display these financial records.

**Non-Goals:**
- Parents will not be able to create, update, or delete billings, installments, or payments (read-only).
- Online payment processing is out of scope (parents just view records).
- Modifying the core financial calculations.

## Decisions

**1. API Endpoint Design**
- *Decision*: Introduce specific parent-facing endpoints (e.g., `GET /parents/students/:studentId/billings`, `GET /parents/students/:studentId/payments`) instead of relaxing the admin endpoints.
- *Rationale*: Admin endpoints often include internal fields, broad search parameters, and lack student-specific scoping out of the box. Parent endpoints can be strictly scoped to a `studentId` in the path, making authorization checks straightforward (verify if `req.user.id` is linked to `studentId`). This prevents accidental data leaks and keeps controllers single-purpose.

**2. Authorization Approach**
- *Decision*: Create an authorization guard/interceptor `IsParentOfStudentGuard` that checks the `student-parent-mapping` to ensure the incoming parent user has a valid link to the `studentId` parameter.
- *Rationale*: Reusable security logic that can wrap any parent-facing endpoint.

## Risks / Trade-offs

- **Risk: Data Leakage to unauthorized parents** → *Mitigation*: The `IsParentOfStudentGuard` must be strictly applied to all new endpoints, failing closed by default if the mapping is absent.
- **Risk: Performance of repeated mapping lookups** → *Mitigation*: The mapping check is a simple database query that can be indexed. In the future, this mapping could be added to the JWT session, but for now, a real-time check ensures immediate revocation if a link is deleted.
