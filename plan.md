# Development Plan: Smart Entrepreneurial Pitching & Matching System (SEPMS)

## Current State
* **Folder Structure:** `/web` (Next.js/React), `/mobile` (Flutter), `/api` (Node.js/Express & Python FastAPI).
* **Completed Features:** Landing page, Authentication (Firebase Auth) for Admin, Entrepreneur, and Investor roles, and initial AI scaffolding.
* **Database:** MongoDB Atlas (Document storage and Vector Indexing).

## Phase 1: Database Schema & Role Profiling
**Goal:** Establish the underlying data models and strictly enforce role-specific profile requirements.
1. **Identity & Profile Schemas:** Implement `entrepreneurProfiles` (tracking KYC, company details) and `investorProfiles` (tracking preferred sectors, investment limits) in the `/api` (Node.js) layer.
2. **KYC Verification Flow:** Build a restricted "Pre-Verification" dashboard in `/web` and `/mobile`. Entrepreneurs must upload business licenses/TINs, and Investors must upload financial accreditation.
3. **Admin Queue:** Create an admin dashboard UI to manually review, approve, or reject pending KYC documents before granting users full platform access.

## Phase 2: Pitch Processing & Document Validation Subsystem
**Goal:** Build the guided submission process with rigorous auto-validation.
1. **Pitch Schemas:** Create Mongoose models for `submissions`, `documents`, and `tags`.
2. **Guided Submission UI:** Implement the multi-step pitch creation form (Summary, Problem, Solution, Team, Financials) with "Save as Draft" functionality.
3. **File Uploads:** Implement chunked media uploads to Cloudinary for large pitch decks and videos.
4. **Pre-Submission Validation Pipeline:**
   * Integrate OCR to extract dates and check for expired documents.
   * Implement readability checks (reject blurry documents based on low OCR confidence).
   * Implement consistency checks (cross-reference extracted entity names across multiple documents to detect conflicts).
   * Route failed validations back to the user with actionable errors.

## Phase 3: AI Analysis & Enrichment Engine
**Goal:** Expand the existing AI scaffolding to process validated pitches and generate machine-readable insights.
1. **Semantic Embeddings:** Use the Python FastAPI service to generate embeddings for the pitch's text (Problem, Solution, Market) using a sentence-transformer model (e.g., all-MiniLM-L6-v2) and store them in the MongoDB Vector Index.
2. **Scoring & Summarization:** Implement a classifier to generate a completeness score and a "Risk Indicator." Generate a short executive summary.
3. **AI Fallback:** If the local model yields low confidence (<75%), redact sensitive PII/IP data and route the text to an external API (like Gemini) for high-accuracy classification.
4. **Text-to-Speech (TTS):** Integrate a TTS component (e.g., Coqui) to generate audio summaries of the pitches in supported languages.

## Phase 4: Matching & Recommendation Subsystem
**Goal:** Connect verified investors with semantically matched pitches.
1. **Recommendation Engine:** Implement a `$vectorSearch` query in MongoDB that matches an Investor's profile embeddings against active pitch embeddings.
2. **Investor Dashboard:** Build the UI to display ranked recommendations. Include the AI-generated summaries, explainability metrics (why a pitch was recommended), and the TTS audio playback button.
3. **Feedback Loop:** Add a "Not Interested" button allowing investors to decline a pitch and provide a reason (e.g., "Wrong Sector"). Use this signal to dynamically update the investor's preference embeddings.

## Phase 5: Communication & Scheduling
**Goal:** Allow matched parties to communicate and negotiate securely.
1. **Secure Messaging:** Build an encrypted, real-time messaging interface between Entrepreneurs and Investors.
2. **Auto-Translation:** Implement a translation middleware hook for the chat if the two parties have different preferred languages.
3. **Meeting Scheduler:** Create a calendar UI allowing Investors to propose time slots and Entrepreneurs to accept them, creating a record in a `meetings` collection.

## Phase 6: Simulated Milestones & Payment Tracking
**Goal:** Track project deliverables and simulate the release of funding tranches.
1. **Milestone Creation:** Build a UI for Entrepreneurs to define project milestones and attach funding amounts.
2. **Verification Flow:** Allow Entrepreneurs to mark milestones as "Complete" and upload proof. 
3. **Investor Approval:** Allow Investors to review the proof and click "Verify and Simulate Payment," updating the milestone to "Paid" and writing an immutable record to a `ledgerEntries` collection.

## Phase 7: Administrative Oversight & Governance
**Goal:** Give admins complete control over platform safety and compliance.
1. **Final Approval Gate:** Create a UI for Admins to perform a final sanity check on all AI-approved pitches before they go live. Allow Admins to manually override AI flags.
2. **Enforcement Tools:** Build endpoints and UI controls to permanently suspend malicious accounts, hide non-compliant pitches, and automatically cancel meetings for suspended users.
3. **Mutual Reporting:** Implement a "Report Misconduct" button in the messaging UI that instantly freezes the chat thread and alerts an admin.
4. **Audit Logging:** Ensure all administrative actions write an immutable entry to an `adminActions` collection.