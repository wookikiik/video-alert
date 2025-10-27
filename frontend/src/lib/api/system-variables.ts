/**
 * API client for system variables endpoint
 *
 * Handles fetching system variables from the backend API with:
 * - Zod validation for type safety
 * - Error handling
 * - Data transformation to UI format
 */

import {
  SystemVariablesResponseSchema,
  type SystemVariablesResponse,
} from "@/lib/schemas/system-variables";

/**
 * UI representation of a system variable
 */
export interface SystemVariable {
  label: string;
  value: string | null;
  configured: boolean;
  type: "text" | "password";
}

/**
 * Error thrown when API request fails
 */
export class SystemVariablesAPIError extends Error {
  constructor(message: string, public statusCode?: number) {
    super(message);
    this.name = "SystemVariablesAPIError";
  }
}

/**
 * Transform backend API response to UI format
 */
function transformToUIFormat(
  response: SystemVariablesResponse
): SystemVariable[] {
  return [
    {
      label: "Monitoring Video Page URL",
      value: response.monitored_video_page_url.value,
      configured: response.monitored_video_page_url.is_set,
      type: "text",
    },
    {
      label: "Telegram Channel ID",
      value: response.telegram_channel_id.value,
      configured: response.telegram_channel_id.is_set,
      type: "text",
    },
    {
      label: "Telegram Bot Token",
      value: response.telegram_bot_token.value,
      configured: response.telegram_bot_token.is_set,
      type: "password",
    },
  ];
}

/**
 * Fetch system variables from the backend API
 *
 * @throws {SystemVariablesAPIError} If the request fails or validation fails
 * @returns Array of system variables in UI format
 */
export async function fetchSystemVariables(): Promise<SystemVariable[]> {
  const apiBaseUrl =
    process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:8000";
  const endpoint = `${apiBaseUrl}/api/v1/admin/system-variables`;

  try {
    const response = await fetch(endpoint, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      },
    });

    if (!response.ok) {
      throw new SystemVariablesAPIError(
        `API request failed: ${response.statusText}`,
        response.status
      );
    }

    const json = await response.json();

    // Validate response with Zod
    const validatedData = SystemVariablesResponseSchema.parse(json);

    // Transform to UI format
    return transformToUIFormat(validatedData);
  } catch (error) {
    if (error instanceof SystemVariablesAPIError) {
      throw error;
    }

    if (error instanceof Error) {
      throw new SystemVariablesAPIError(
        `Failed to fetch system variables: ${error.message}`
      );
    }

    throw new SystemVariablesAPIError("An unknown error occurred");
  }
}
