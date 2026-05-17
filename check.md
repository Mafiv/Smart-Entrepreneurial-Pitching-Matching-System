# SEPMS System Flow & Architectural Compliance Requirements

**Instructions for AI Coding Assistant:** Please perform an exhaustive scan of the codebase and verify if the backend routes, database schemas, middleware, and background workers comply with the following structural and logical requirements from the SEPMS specification. For each section, report:
1. **Implementation Status:** (Fully Implemented / Partially Implemented / Missing)
2. **File Paths:** Identify the exact files handling this logic.
3. **Compliance Level & Deviations:** Note any missing validations, missing error boundaries, or hardcoded bypasses.

---

## 1. Authentication, Role Management, & Onboarding Pipelines

### SC-01 to SC-04: User Lifecycle & Restricted Dashboards
* **Distinct Registration Pipelines:** * The registration logic must process `Entrepreneur` and `Investor` roles via distinct parameters or endpoints.
  * Schema check: Validate that roles are enforced by strict enum types (`'Entrepreneur'`, `'Investor'`, `'Admin'`).
* **Pre-Verification State Isolation:** * Upon initial registration, the user account status must default to a restricted state (e.g., `PendingVerification`).
  * Middleware enforcement: Any request from an unverified user to core endpoints (e.g., matching engines, active messaging, pitch submission to the investor pool) must be blocked with an HTTP `403 Forbidden` error. 
  * Access must be completely restricted to a "Pre-Verification Dashboard" or file-upload route until mandatory registration/KYC documents are uploaded.
* **Role-Based Dynamic Routing & Token Inspection:** * The login/session initiation service must parse user claims and inspect both `role` and `verificationStatus`.
  * Ensure that routing mechanisms or access control lists (ACL) reject users with disabled, suspended, or unverified states, redirecting them strictly to their assigned portal.
* **OTP-Based Account Recovery Workflow:**
  * Password reset must not be direct. The flow must require:
    1. Generation of a cryptographically secure, time-sensitive One-Time Password (OTP).
    2. Dispatching via a verified channel (SMS/Email).
    3. State tracking in the database with an explicit expiration window (e.g., 5–10 minutes).
    4. Invalidation of the OTP immediately upon a single use or after failure thresholds are crossed.

---

## 2. Pitch Creation & Draft Management Flows

### SC-05, SC-11, SC-12: Input Structuring & Media Pipelines
* **Structured Section Validation:** * Pitch generation logic must require discrete inputs for *Problem Statement*, *Proposed Solution*, *Market Analysis*, and *Financial Outlines*.
* **Draft State Constraints & Pipeline Isolation:**
  * The application must support a structural `Draft` state. 
  * If mandatory documents (e.g., TIN, Business Registration Certificates, or core financial parameters) are missing, the pitch entity status must remain fixed as `Draft`.
  * *Critical Execution Guard:* Ensure that no background worker or database query pulls entities with a `Draft` status into the AI evaluation queue or active vector index matching pipeline.
* **Chunked Uploads for Heavy Media Assets:**
  * For pitch videos or extensive collateral (>50MB), the codebase must avoid monolithic HTTP POST uploads.
  * Verify implementation of chunked file transfer pipelines (e.g., direct-to-cloud signed URL chunking or Multipart uploads via services like Cloudinary/S3).
  * Check that resource-heavy post-processing tasks—such as file indexing, compression, or virus scans—are offloaded to asynchronous task workers (e.g., BullMQ, Celery) to prevent blocking main runtime threads.

---

## 3. Automated Document Validation & OCR Engine

### SC-06 to SC-09, SC-13, SC-15: Content and Metadata Integrity Controls
* **Completeness Pre-Validation Gate:**
  * Prior to final pitch submission, a validation middleware must verify that all required legal and financial entity slots (TIN, Memorandum of Association, Articles of Association, Valid Business License) are populated with valid file references.
* **Semantic Mismatch Detection (OCR Payload Processing):**
  * The system must execute Optical Character Recognition (OCR) or text extraction on uploaded document attachments.
  * Search the codebase for validation logic that checks the extracted string layout against expected document semantics. For instance, if an image containing general objects or a standard product photo is submitted instead of an official text document, the validation engine must flag it as an `Incorrect Upload Type` and halt the flow.
* **Temporal Validity Check (Expiration Logic):**
  * Check that the system parses or receives structured dates corresponding to the document's `Issue Date` and `Expiry Date`.
  * The validation engine must compare the document's `Expiry Date` against the current system UTC date. If the document is expired, the system must set the pitch status to `Rejected/NeedsUpdate` and block submission.
* **Readability & Confidence Score Thresholds:**
  * The OCR processor must return a clarity/confidence score.
  * The codebase must declare a hardcoded or configured minimum threshold (e.g., `CONFIDENCE_THRESHOLD = 0.50`). If the processing library returns a score below this value (due to blur, low resolution, or obstruction), the flow must fail with an explicit `Unreadable Document Error` prompting a re-upload.
* **Cross-Document Field Alignment (Identity Conflict Detection):**
  * The backend must cross-reference text strings extracted from different files.
  * Specifically, match the corporate name, registration numbers, or owner identifiers across the TIN document and the Business License. If a string distance algorithm or exact match fails, a `Cross-Document Conflict` state must trigger, blocking automated approval and routing the record to an Admin review queue.
* **Multi-Entity Isolation Check:**
  * Ensure the system checks file metadata or extracted text signatures to verify that all uploaded documentation belongs to the *same* legal business entity. If documents from Entity A and Entity B are mixed within a single pitch profile, the system must fail validation.

---

## 4. AI Evaluation & Recommendation Pipelines

### SC-16, SC-18, SC-19, SC-22: Semantic Search & Embedding Life-Cycles
* **Asynchronous Embedding Generation Worker:**
  * Upon a pitch clearing initial validation, a non-blocking background worker must extract textual payloads (*Problem, Solution, Market Description*).
  * The text must be passed to a transformer model embedding service (e.g., local model runtime or external API) to generate high-dimensional vectors, which must be indexed immediately into a vector store.
* **Classifier Completeness & Quality Scoring:**
  * Prior to storage, the raw data must clear an internal classifier service that assigns a *Completeness Score*, *Risk Vector*, and *Relevance Indicator*. Ensure these properties are committed to the pitch database schema.
* **AI Confidence Fallback Architecture (Hybrid Validation Chain):**
  * If the internal classification model yields low confidence scores, look for a fallback handler mechanism.
  * This handler must sanitize the data by scrubbing Personally Identifiable Information (PII) and Intellectual Property (IP) identifiers before dispatching a secure, stripped payload to an external LLM API (e.g., Gemini or GPT models) for secondary structural classification.
* **Vector Similarity Matching Loop:**
  * The investor feed recommendation service must execute vector similarity computations (e.g., Cosine Similarity or Dot Product queries via your vector database).
  * The algorithm must query active pitch embeddings against the preference and history embeddings stored inside the active `Investor` profile.
* **Negative Feedback Loop & Vector Refinement:**
  * Search the codebase for an event handler corresponding to actions like "Not Interested" or "Pass on Pitch".
  * When an investor skips a pitch, the system must:
    1. Log the rejection context and categorical tags.
    2. Recalculate or apply a penalty vector shift to the investor's active preference embedding to actively suppress similar profile shapes in subsequent feed generation cycles.

---

## 5. Milestone Tracking & Communication Infrastructure

### SC-20, SC-21: Escrow Simulations & Secure Collaboration Channels
* **Encrypted Message Channel Handshake:**
  * Messaging channels must not be open by default. A channel initialization service must only execute after an Investor explicitly issues a connection request and the Entrepreneur accepts, or vice-versa.
  * Look for communication hooks handling real-time runtime translations if opposing users have mismatched locale/language system variables.
* **Calendar & Slot Selection Scheduling Integration:**
  * Verify the existence of a meeting scheduler system that blocks off matched time matrices between investor and entrepreneur profiles, records state hooks, and updates connection states upon successful scheduling.
* **Simulated Post-Investment Milestone & Tranche Management:**
  * Check for a milestone tracking schema where:
    1. The Entrepreneur records completed work packages and uploads execution evidence.
    2. The Investor receives a validation state prompt to approve or reject the work package evidence.
    3. On investor approval, a state controller simulates a funding tranche release, generating a mock financial immutable logging entry recording the transfer balance state.

---

## 6. Administrative Oversight & Security Enforcement

### SC-10, SC-14, SC-17, SC-23 to SC-27: System Control Gates & Interventions
* **Automated Fraud Flag Execution:**
  * If the automated document or layout processing systems flag formatting anomalies, text mismatches, or suspicious OCR variance, the system must forcefully alter the pitch state to `SuspectContent`.
  * This state must prevent the pitch from appearing in any public queries or investor matches.
* **Administrative Override & Audit Logging:**
  * Look for an explicit Admin route capable of clearing `SuspectContent` or `ValidationFailed` states (handling false positives).
  * *Security Requirement:* This action must trigger a permanent database log insertion inside an audit trail collection, capturing the `AdminUserID`, `Timestamp`, `TargetPitchID`, and `JustificationText`.
* **Final Human Approval Gate (Admin Release):**
  * Even if a pitch passes all automated AI metrics and validation protocols cleanly, it must remain in a `PendingAdminApproval` state. It must *never* be exposed to the public matching engine until an administrator calls the explicit approval endpoint.
* **Account/Pitch Enforcement Operations (Revocation Architecture):**
  * Locate the user/pitch suspension services. When an Admin suspends an account or a specific pitch, the operation must immediately cascade:
    1. Invalidate or revoke all active authorization tokens (JWTs/sessions) for the targeted entity.
    2. Toggle pitch visibility indexes instantly to false (`published: false`).
    3. Freeze and lock all active message threads linked to the entity, rejecting incoming WebSockets or API mutations with an immediate authorization exception.
* **Mutual Misconduct Reporting System:**
  * In the messaging modules, search for a "Report" action hook available to both roles. 
  * Triggering this action must execute an atomic transaction that puts the message thread into a `Suspended/UnderReview` state and appends the conversation log reference to an Admin triage queue immediately.