# SEPMS Feature Implementation Checklist

## 1. Authentication & Identity Management
* **Role-Based Registration:** Users must be able to sign up as one of three distinct roles: Entrepreneur, Investor, or Administrator.
* **Federated Auth & OTP:** Registration and login must be handled via an external authentication provider (Firebase Auth), utilizing email/phone and password, alongside OTP or verification links.
* **Password Recovery:** A secure "Forgot Password" workflow utilizing a time-based OTP sent to the verified communication channel.
* **Session Security:** The backend API must enforce stateless token exchange (JWT) and handle token revocation for suspended accounts.

## 2. User Profiles & Role Management
* **Pre-Verification Gate:** New users must be placed in a restricted "Registered/Unverified" dashboard until they complete their respective KYC or financial standing document uploads.
* **Entrepreneur Profiles:** Must track business-specific data, including `companyName`, and boolean flags indicating verification status.
* **Investor Profiles:** Must capture dynamic preferences such as `preferredSectors`, `minInvestment`, `maxInvestment`, and `investmentType` to fuel the recommendation engine.

## 3. Pitch Processing & Document Handling
* **Guided Submission Forms:** Entrepreneurs must have a multistep form capturing Title, Funding Goal, Summary, Sector, and Stage.
* **Draft Saving:** The system must allow users to save partially completed pitches and return to them later.
* **Mandatory Document Checklist:** A dynamic upload checklist requiring specific files (e.g., Business License, TIN, MoA/AoA, Financial Statements, Pitch Deck).
* **Large File Handling:** Integration with an external storage service (Cloudinary) utilizing chunked uploads to handle large media files (>50MB) without timing out.

## 4. AI Pre-Validation & Quality Checking
* **Synchronous Pre-Validation:** The backend must actively block submissions if mandatory files are missing from the checklist.
* **Content Mismatch Detection:** Utilizing OCR and a local classifier (via the Python/FastAPI service) to ensure the uploaded file content matches the requested document type (e.g., rejecting an image uploaded in place of a legal PDF).
* **Expiration Date Validation:** Rule-based logic extracting dates via OCR to block expired business licenses.
* **Readability Check:** The system must reject documents where the OCR engine returns a confidence score below a defined threshold (e.g., < 50%).
* **Cross-Document Conflict Detection:** AI anomaly checking to cross-reference extracted strings (like business names) across different documents to detect multi-entity conflicts or fraud.
* **AI Fallback Mechanism:** If the local classifier yields low confidence (< 75%), the system must automatically redact sensitive data and trigger a call to an external AI API (like Gemini/GPT) for structured analysis, logging the API call for auditing.

## 5. Semantic Matching & Recommendation Engine
* **Embedding Generation:** The AI service must generate transformer-based sentence embeddings (e.g., MiniLM) for the pitch's problem statement, solution, business model, and market description.
* **Metric Calculation:** The pipeline must compute a "Relevance Score" and a "Risk Indicator" for each submission.
* **Vector Storage & Search:** Embeddings must be persisted in a MongoDB Atlas Vector Index to enable real-time semantic similarity queries against investor preference embeddings.

## 6. Investor Dashboard & Accessibility Tools
* **Personalized Feeds:** Investors must see a ranked dashboard of pitches filtered by their generated relevance and risk scores.
* **AI-Assisted Summaries & Explainability:** The UI must display an AI-generated textual summary of the pitch alongside explainable scoring rationale (why the pitch was matched to them).
* **Voice/Multilingual Output (TTS):** A Text-to-Speech component (e.g., Coqui) must allow investors to listen to the AI summary in supported languages (English and Amharic).

## 7. Communication & Milestone Tracking
* **Secure Messaging:** An encrypted, in-app messaging channel that is specific to the investor-entrepreneur pair.
* **Real-Time Translation:** The messaging interface must support live text translation if the two parties have different preferred language settings.
* **Meeting Scheduling:** A calendar integration tool allowing investors to share available time slots and entrepreneurs to confirm meetings.
* **Simulated Payments:** A milestone tracker where entrepreneurs upload completion evidence, investors verify it, and the system simulates a funding tranche release, recording it in an immutable ledger.
* **Negative Feedback Loop:** If an investor declines a pitch, they can input a rejection reason which immediately feeds back into the AI to update their vector profile.

## 8. Administrative Oversight & Governance
* **Approval Queues:** Admin dashboards must have interfaces to manually review and approve investor financial credentials and final entrepreneur pitch submissions before they go live.
* **AI Override:** Admins must have the ability to review documents flagged as "Suspect" by the AI and manually click "Override AI Decision" for false positives.
* **Content & User Enforcement:** Tools to suspend or permanently remove fraudulent pitches, and to immediately freeze an account (disabling login and active chats) based on reports.
* **Audit Logging:** Every administrative action (approvals, overrides, suspensions) and simulated payment must be immutably recorded in an audit log.