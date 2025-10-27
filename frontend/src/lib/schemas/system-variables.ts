/**
 * Zod schemas for system variables API responses
 *
 * These schemas validate the data returned from the backend API:
 * GET /api/v1/admin/system-variables
 */

import { z } from "zod";

/**
 * Schema for a single system variable detail
 *
 * Matches backend schema: SystemVariableDetail
 */
export const SystemVariableDetailSchema = z.object({
  value: z.string().nullable(),
  is_set: z.boolean(),
  hint: z.string(),
});

/**
 * Schema for the complete system variables API response
 *
 * Matches backend schema: SystemVariablesResponse
 */
export const SystemVariablesResponseSchema = z.object({
  monitored_video_page_url: SystemVariableDetailSchema,
  telegram_channel_id: SystemVariableDetailSchema,
  telegram_bot_token: SystemVariableDetailSchema,
});

/**
 * TypeScript types extracted from Zod schemas
 */
export type SystemVariableDetail = z.infer<typeof SystemVariableDetailSchema>;
export type SystemVariablesResponse = z.infer<typeof SystemVariablesResponseSchema>;
