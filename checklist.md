# Smart Entrepreneurial Pitching & Matching System (SEPMS) - Requirements & Functionalities Checklist

This checklist is derived from the "Senior Project Documentation" to help you verify that the developed system meets all the promised requirements and use cases.

## 1. Functional Requirements

1. **User Management & Authentication**
   - [ ] 1.1. Registration and initial verification for Entrepreneurs.
   - [ ] 1.2. Registration and financial verification for Investors.
   - [ ] 1.3. Secure user login and authentication.
   - [ ] 1.4. Password recovery via OTP (One-Time Password).
2. **Pitch Submission Module (Entrepreneur)**
   - [ ] 2.1. Guided submission templates (Title, Funding Goal, Summary).
   - [ ] 2.2. Draft saving capability for partial submissions.
   - [ ] 2.3. Multistep, chunked file upload supporting large media files (>50MB).
   - [ ] 2.4. Automatic pre-validation checks for missing mandatory documents.
3. **AI Evaluation & Validation Engine**
   - [ ] 3.1. OCR-based text extraction from uploaded legal documents.
   - [ ] 3.2. Automated classification to detect content mismatches (e.g., uploading an image instead of a legal PDF).
   - [ ] 3.3. Expiration date checks for time-sensitive documents (e.g., Business License).
   - [ ] 3.4. Structural anomaly and potential fraud detection.
   - [ ] 3.5. Cross-document data conflict detection (e.g., differing business names on TIN vs. License).
   - [ ] 3.6. Multi-entity conflict detection (identifying if documents belong to different legal entities).
   - [ ] 3.7. AI confidence-based fallback (routing low-confidence AI classifications to human admin review).
   - [ ] 3.8. Background processing of files for virus scanning and indexing without blocking the UI.
4. **Investor Matching & Review**
   - [ ] 4.1. Vector-based semantic matching to recommend relevant pitches to investors.
   - [ ] 4.2. Voice-enabled summaries of pitches (Text-to-Speech integration).
   - [ ] 4.3. Multilingual text support.
   - [ ] 4.4. Interface for investors to review, accept, or reject recommendations.
5. **Communication & Milestones**
   - [ ] 5.1. In-app messaging/chat threads between matched Entrepreneurs and Investors.
   - [ ] 5.2. Meeting scheduling requests and notifications.
   - [ ] 5.3. Milestone creation for funded projects.
   - [ ] 5.4. Simulated payment tracking (sandbox deposit and release based on milestone completion).
6. **Administrative Dashboard**
   - [ ] 6.1. Queue for viewing AI-flagged or suspicious submissions.
   - [ ] 6.2. Ability to override AI decisions (marking false positives as valid).
   - [ ] 6.3. Final administrative approval gateway for verified pitches.
   - [ ] 6.4. User management (suspending/removing Entrepreneur or Investor accounts).
   - [ ] 6.5. Oversight of user reports (e.g., investigating suspicious users).

## 2. Non-Functional Requirements

1. **Performance & Architecture**
   - [ ] 1.1. Separation of concerns: long-running AI tasks (embeddings, classification) delegated to a specialized Python service to prevent UI blocking.
   - [ ] 1.2. Asynchronous background processing for uploads.
2. **Security & Reliability**
   - [ ] 2.1. Audit logging for all Administrator actions (recording timestamps and override justifications).
   - [ ] 2.2. Secure storage of structured data in a document-oriented DB and vectors in a specialized index.
3. **Usability**
   - [ ] 3.1. Cross-platform availability (Web for Investors/Admins, Mobile for Entrepreneurs).

## 3. Comprehensive Use Case (UC) Checklist

### User Access & Onboarding
- [ ] **UC-01:** Entrepreneur Sign Up & Initial Verification
- [ ] **UC-02:** Investor Sign Up & Financial Verification
- [ ] **UC-03:** Successful User Authentication (Login)
- [ ] **UC-04:** Password Recovery (Forgot Password)

### Pitch Creation & Uploads
- [ ] **UC-05:** Full Pitch Creation and AI Submission
- [ ] **UC-11:** Partial Submission and Draft Saving
- [ ] **UC-12:** Multistep Upload (Handling Large Media Files)

### Automated Validation & Flagging
- [ ] **UC-06:** Submission Data Validation Failure (Missing Required Documents)
- [ ] **UC-07:** Document Content Mismatch Failure (Wrong Document Uploaded)
- [ ] **UC-08:** Expired or Outdated Document Submission
- [ ] **UC-09:** Low-Quality/Unreadable Document Scenario
- [ ] **UC-10:** Fraud or Suspicious Document Scenario
- [ ] **UC-13:** Cross-Document Data Conflict
- [ ] **UC-15:** Multi-Business Entrepreneur (Conflict of Entities)
- [ ] **UC-16:** AI Confidence-Based Fallback (Hybrid Checker)

### Administrator Workflows
- [ ] **UC-14:** Administrator Correction and AI Override
- [ ] **UC-17:** Admin Approves Entrepreneur Submission (Final Gate)
- [ ] **UC-23:** Admin Removal or Suspension of Pitch
- [ ] **UC-24:** Entrepreneur Account Suspension
- [ ] **UC-25:** Investor Account Suspension

### Matching & Post-Match Interactions
- [ ] **UC-18:** AI Evaluation and Scoring Pipeline
- [ ] **UC-19:** Investor Recommendation, Review, and Voice Output
- [ ] **UC-20:** Communication and Meeting Scheduling
- [ ] **UC-21:** Milestone Payment Simulation and Tracking
- [ ] **UC-22:** Proposal Rejection (Investor Declines Pitch)

### Reporting
- [ ] **UC-26:** Investor Reports Suspicious Entrepreneur
- [ ] **UC-27:** Entrepreneur Reports Suspicious Investor