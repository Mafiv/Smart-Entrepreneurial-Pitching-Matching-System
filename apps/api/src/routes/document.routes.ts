import { Router } from "express";

import { DocumentController } from "../controllers/document.controller";
import { authenticate, authorize } from "../middleware/auth";
import {
	multipleDocumentUpload,
	singleDocumentUpload,
} from "../middleware/upload";

const router = Router();

router.use(authenticate);

/**
 * @openapi
 * tags:
 *   - name: Documents
 *     description: Document upload and processing
 */

/**
 * @openapi
 * /api/documents:
 *   post:
 *     tags: [Documents]
 *     summary: Upload document
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required: [file]
 *             properties:
 *               file:
 *                 type: string
 *                 format: binary
 *               type:
 *                 $ref: '#/components/schemas/DocumentType'
 *               submissionId:
 *                 type: string
 *     responses:
 *       201:
 *         description: Document uploaded
 *       400:
 *         description: Validation error
 *       401:
 *         description: Unauthorized
 */
router.post(
	"/",
	authorize("entrepreneur", "investor"),
	singleDocumentUpload,
	DocumentController.upload,
);

/**
 * @openapi
 * /api/documents/upload:
 *   post:
 *     tags: [Documents]
 *     summary: Upload single document
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required: [file]
 *             properties:
 *               file:
 *                 type: string
 *                 format: binary
 *               type:
 *                 $ref: '#/components/schemas/DocumentType'
 *     responses:
 *       201:
 *         description: Document uploaded
 */
router.post(
	"/upload",
	authorize("entrepreneur", "investor"),
	singleDocumentUpload,
	DocumentController.uploadSingle,
);

/**
 * @openapi
 * /api/documents/upload-multiple:
 *   post:
 *     tags: [Documents]
 *     summary: Upload multiple documents
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required: [files]
 *             properties:
 *               files:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *               type:
 *                 $ref: '#/components/schemas/DocumentType'
 *     responses:
 *       201:
 *         description: Documents uploaded
 */
router.post(
	"/upload-multiple",
	authorize("entrepreneur", "investor"),
	multipleDocumentUpload,
	DocumentController.uploadMultiple,
);

/**
 * @openapi
 * /api/documents:
 *   get:
 *     tags: [Documents]
 *     summary: List my documents
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Documents list
 */
router.get(
	"/",
	authorize("entrepreneur", "investor", "admin"),
	DocumentController.listMyDocuments,
);

/**
 * @openapi
 * /api/documents/{id}:
 *   get:
 *     tags: [Documents]
 *     summary: Get document by id
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Document fetched
 *       404:
 *         description: Not found
 */
router.get(
	"/:id",
	authorize("entrepreneur", "investor", "admin"),
	DocumentController.getById,
);

/**
 * @openapi
 * /api/documents/{id}/validation:
 *   get:
 *     tags: [Documents]
 *     summary: Get validation/processing status for a document
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Validation status fetched
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ValidationStatusResponse'
 *       404:
 *         description: Not found
 */
router.get(
	"/:id/validation",
	authorize("entrepreneur", "investor", "admin"),
	DocumentController.getValidationStatus,
);

/**
 * @openapi
 * /api/documents/{id}:
 *   delete:
 *     tags: [Documents]
 *     summary: Delete owned document
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Document deleted
 *       404:
 *         description: Not found
 */
router.delete(
	"/:id",
	authorize("entrepreneur", "investor"),
	DocumentController.remove,
);

/**
 * @openapi
 * /api/documents/{id}/override:
 *   post:
 *     tags: [Documents]
 *     summary: Administrator override of AI failure/flag (UC-14)
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *     responses:
 *       200:
 *         description: Document status successfully overridden
 */
router.post(
	"/:id/override",
	authorize("admin", "super_admin"),
	DocumentController.overrideStatus,
);

/**
 * @openapi
 * /api/documents/conflicts/check:
 *   get:
 *     tags: [Documents]
 *     summary: UC-13 - Check for document conflicts across user's documents
 *     description: Cross-references data extracted from different documents, detects conflicts (e.g., mismatched business names), and returns conflict report.
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: submissionId
 *         schema:
 *           type: string
 *         description: Optional submission ID to limit conflict check
 *       - in: query
 *         name: documentIds
 *         schema:
 *           type: string
 *         description: Comma-separated list of document IDs to check
 *     responses:
 *       200:
 *         description: Conflict check completed
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                 hasConflicts:
 *                   type: boolean
 *                 summary:
 *                   type: object
 *                   properties:
 *                     total:
 *                       type: number
 *                     critical:
 *                       type: number
 *                     high:
 *                       type: number
 *                     medium:
 *                       type: number
 *                     low:
 *                       type: number
 *                 conflicts:
 *                   type: array
 *       401:
 *         description: Unauthorized
 */
router.get(
	"/conflicts/check",
	authorize("entrepreneur", "investor", "admin"),
	DocumentController.checkConflicts,
);

/**
 * @openapi
 * /api/documents/{id}/entities:
 *   get:
 *     tags: [Documents]
 *     summary: UC-13 - Get extracted entities for a specific document
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Entities fetched
 *       404:
 *         description: Not found
 */
router.get(
	"/:id/entities",
	authorize("entrepreneur", "investor", "admin"),
	DocumentController.getDocumentEntities,
);

/**
 * @openapi
 * /api/documents/{id}/conflicts:
 *   get:
 *     tags: [Documents]
 *     summary: UC-13 - Get conflict status for a specific document
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Conflict status fetched
 *       404:
 *         description: Not found
 */
router.get(
	"/:id/conflicts",
	authorize("entrepreneur", "investor", "admin"),
	DocumentController.getConflictStatus,
);

/**
 * @openapi
 * /api/documents/{id}/conflicts/override:
 *   post:
 *     tags: [Documents]
 *     summary: UC-13 - Admin override for conflict status (Human resolution)
 *     description: Allows administrator to override detected conflicts and approve document for submission.
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               note:
 *                 type: string
 *                 description: Admin note for override reason
 *     responses:
 *       200:
 *         description: Conflict status overridden
 *       403:
 *         description: Forbidden - Admin only
 *       404:
 *         description: Not found
 */
router.post(
	"/:id/conflicts/override",
	authorize("admin", "super_admin"),
	DocumentController.overrideConflictStatus,
);

/**
 * @openapi
 * /api/documents/conflicts/multi-entity:
 *   get:
 *     tags: [Documents]
 *     summary: UC-3.7 - Check for multi-entity conflicts
 *     description: Detects when documents appear to belong to different legal entities (e.g., different business names or TINs across documents).
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: submissionId
 *         schema:
 *           type: string
 *         description: Optional submission ID to limit conflict check
 *       - in: query
 *         name: documentIds
 *         schema:
 *           type: string
 *         description: Comma-separated list of document IDs to check
 *     responses:
 *       200:
 *         description: Multi-entity conflict check completed
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                 hasMultiEntityConflict:
 *                   type: boolean
 *                 multiEntityConflicts:
 *                   type: array
 *                 summary:
 *                   type: object
 *                   properties:
 *                     total:
 *                       type: number
 *                     critical:
 *                       type: number
 *                     high:
 *                       type: number
 *                 message:
 *                   type: string
 *       401:
 *         description: Unauthorized
 */
router.get(
	"/conflicts/multi-entity",
	authorize("entrepreneur", "investor", "admin"),
	DocumentController.checkMultiEntityConflicts,
);

export default router;
