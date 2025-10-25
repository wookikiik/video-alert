**Context**

- Part of the "Configure Single Video Page URL" story. Frontend task: build an admin-only read-only UI that displays the monitored video page URL and Telegram channel ID.
- The UI consumes a backend read-only GET endpoint (suggested: GET /admin/system-variables) that returns the environment values plus machine-readable presence flags and human hints. Backend will not expose secrets (bot token).
- Frontend stack: Next.js (React, TypeScript), shadcn/ui components, existing admin route/auth patterns.

**Goals**

- Add an admin-only route/view that fetches system variables from the backend and displays:
  - Monitored video page URL
  - Telegram channel ID
- Show contextual help that these values come from environment variables and must be updated server-side (no UI editing).
- Handle loading, error, and empty/missing states gracefully.
- Provide copy-to-clipboard and optional masking for sensitive-looking values; ensure copy works while masked.
- Do not include edit controls; do not send updates to backend.

**Technical Guidelines**

- Route & access:

  - Add a new admin route (e.g., /admin/system-variables) using the repository’s existing admin route/layout and auth guard pattern so the page is accessible only to authenticated admin users.
  - Use existing admin layout, nav and styles to integrate the page consistently.

- API contract (consume-only):

  - Call the read-only endpoint (GET /admin/system-variables). Expect a stable JSON shape containing at least:
    - monitored_url?: string | null
    - telegram_channel_id?: string | null
    - has_monitored_url: boolean
    - has_telegram_channel_id: boolean
    - hints?: { monitored_url?: string; telegram_channel_id?: string }
  - Treat fields as optional; do not assume backend will return secrets (bot token). If backend response differs, implement a small adapter/mapper to the UI model.

- UI behavior & states:

  - Loading: show a spinner or skeleton for the two fields.
  - Error: show a clear error message and a button to retry the GET request.
  - Missing values: when has\_\* flag is false or field value is empty/null, render a clear "Not configured" placeholder and show the provided hint (or a default hint like "Update server .env and restart the server"). Provide copy-to-clipboard disabled for missing values.
  - Display: render each variable in a read-only card/row with:
    - Label (e.g., "Monitored video page URL")
    - Value (masked by default if it looks sensitive; otherwise plain)
    - Presence indicator (e.g., success/warning badge driven by has\_\* flags)
    - Copy-to-clipboard button (always available for present values)
    - Small help text explaining “These values are sourced from the server environment (.env). Edit on the server and redeploy/restart to update.”
  - Masking: mask values that are likely secrets (long opaque tokens) by default and provide a Reveal/Hide toggle. Ensure copy uses the real underlying value even when masked.
  - Accessibility: buttons and inputs must have accessible labels; keyboard-navigable.

- Implementation constraints:

  - Use existing shadcn/ui components and styling conventions (Card, Button, Tooltip, Badge, Skeleton, Clipboard/Toast if present).
  - Use the project’s standard data fetching utilities/hooks (e.g., existing fetch wrapper, SWR/react-query) and error/toast patterns.
  - Avoid persisting or caching these values beyond normal UI state; fetch on mount and allow manual refresh.
  - Do not attempt to read/write process env directly in client code.
  - Do not attempt to display or fetch bot tokens or other secrets. If the API returns any field flagged as sensitive, mask it and do not log it to console.

- UX notes:
  - Keep UI minimal and informative — no edit controls or forms.
  - Provide copy feedback (toast/snack) on successful copy.
  - Provide an inline link or instruction on how to update env vars (e.g., “Update .env on server / redeploy to apply”) — prefer the hint text returned by backend when present.

**Out of scope**

- Any backend changes or creation of the read-only endpoint (assume GET /admin/system-variables is available).
- Editing/updating or validating environment variables from the UI.
- Exposing or handling bot token or other secrets.
- Building schedule or logs UI—only display system variables.

**Suggested research**

- Inspect existing admin routes/layout and auth guard usage to replicate access control and route placement.
- Find the project's API client/fetch helper and toast/copy utilities to follow conventions.
- Review existing shadcn/ui components usage in admin pages for consistent markup and patterns (Cards, Buttons, Badges, Skeletons).
- Check any existing clipboard/copy-to-clipboard utility or component used in the repo.

---

## Implementation Checklist

### Phase 1: Prerequisites & Infrastructure Setup

- [ ] **Install shadcn/ui components**
  - [ ] `npx shadcn-ui@latest add card`
  - [ ] `npx shadcn-ui@latest add button`
  - [ ] `npx shadcn-ui@latest add badge`
  - [ ] `npx shadcn-ui@latest add skeleton`
  - [ ] `npx shadcn-ui@latest add input`
  - [ ] `npx shadcn-ui@latest add tooltip`

- [ ] **Install toast notification system**
  - [ ] `npm install sonner`
  - [ ] Configure Toaster in root layout

- [ ] **Create utility functions**
  - [ ] Create `frontend/src/lib/api.ts` - API client with base URL and auth header injection
  - [ ] Create `frontend/src/lib/clipboard.ts` - Clipboard helper with toast feedback
  - [ ] Create `frontend/src/types/system-variables.ts` - TypeScript types for API response

- [ ] **Set up authentication infrastructure**
  - [ ] Create `frontend/src/lib/auth.ts` - Admin token storage/retrieval
  - [ ] Create auth context or hook for token management
  - [ ] Implement route guard pattern for `/admin/*` routes

### Phase 2: Admin Route Structure

- [ ] **Create admin directory structure**
  - [ ] Create `frontend/src/app/admin/` directory
  - [ ] Create `frontend/src/app/admin/layout.tsx` (if shared admin layout needed)
  - [ ] Create `frontend/src/app/admin/system-variables/` directory

- [ ] **Implement route guard**
  - [ ] Add auth check middleware to admin layout or page
  - [ ] Redirect unauthenticated users to login/home

### Phase 3: System Variables Page Implementation

- [ ] **Create main page component**
  - [ ] Create `frontend/src/app/admin/system-variables/page.tsx`
  - [ ] Mark as client component with `"use client"`
  - [ ] Set up basic page structure with heading

- [ ] **Implement data fetching**
  - [ ] Create API call hook using fetch/SWR
  - [ ] Call `GET /api/v1/admin/system-variables` with auth header
  - [ ] Map backend response to UI model (adapter if needed)

- [ ] **Implement loading state**
  - [ ] Show Skeleton components for each variable field
  - [ ] Display loading indicator

- [ ] **Implement error state**
  - [ ] Show clear error message
  - [ ] Add "Retry" button to refetch data
  - [ ] Handle network errors and 401 unauthorized

- [ ] **Implement variable display cards**
  - [ ] Create reusable `SystemVariableCard` component
  - [ ] Display label (e.g., "Monitored video page URL")
  - [ ] Display value or "Not configured" placeholder
  - [ ] Add presence indicator badge (success/warning)
  - [ ] Add help text about env vars

- [ ] **Implement copy-to-clipboard**
  - [ ] Add copy button for each configured value
  - [ ] Disable copy button for missing values
  - [ ] Show toast notification on successful copy
  - [ ] Handle copy errors gracefully

- [ ] **Implement value masking (if needed)**
  - [ ] Detect sensitive-looking values (bot token)
  - [ ] Mask by default with reveal/hide toggle
  - [ ] Ensure clipboard copy uses real value even when masked

- [ ] **Handle bot token field**
  - [ ] Display bot token status (is_set flag)
  - [ ] Show hint: "Set (value withheld for security)"
  - [ ] Do not attempt to display or copy the token value
  - [ ] Show appropriate badge (configured vs not configured)

### Phase 4: Accessibility & UX Polish

- [ ] **Accessibility improvements**
  - [ ] Add ARIA labels to all buttons
  - [ ] Ensure keyboard navigation works
  - [ ] Test with screen reader
  - [ ] Add focus visible styles

- [ ] **UX enhancements**
  - [ ] Add manual refresh button
  - [ ] Show last updated timestamp (optional)
  - [ ] Add tooltips for helpful information
  - [ ] Ensure responsive design (mobile/tablet)

### Phase 5: Testing & Validation

- [ ] **Manual testing**
  - [ ] Test with all variables configured
  - [ ] Test with missing variables
  - [ ] Test with partial configuration
  - [ ] Test copy functionality
  - [ ] Test error states and retry
  - [ ] Test loading states

- [ ] **Authentication testing**
  - [ ] Test access without admin token (should redirect/error)
  - [ ] Test with invalid admin token
  - [ ] Test with valid admin token

- [ ] **Cross-browser testing**
  - [ ] Test in Chrome
  - [ ] Test in Firefox
  - [ ] Test in Safari

### Phase 6: Documentation & Cleanup

- [ ] **Code cleanup**
  - [ ] Remove console.logs
  - [ ] Add JSDoc comments to functions
  - [ ] Ensure TypeScript strict mode compliance

- [ ] **Documentation**
  - [ ] Update README if needed
  - [ ] Add inline code comments for complex logic
  - [ ] Document environment variable requirements

---

## Backend API Contract Reference

**Endpoint:** `GET /api/v1/admin/system-variables`

**Headers Required:**
```
X-Admin-Token: <admin-token>
```

**Response Schema:**
```typescript
{
  monitored_video_page_url: {
    value: string | null,          // URL or null if not set
    is_set: boolean,                // true if env var exists and non-empty
    hint: string                    // Human-readable status message
  },
  telegram_channel_id: {
    value: string | null,          // Channel ID or null if not set
    is_set: boolean,
    hint: string
  },
  telegram_bot_token: {
    value: null,                   // Always null (withheld for security)
    is_set: boolean,               // true if env var exists and non-empty
    hint: string                   // Usually "Set (value withheld for security)"
  }
}
```

**Example Response (all configured):**
```json
{
  "monitored_video_page_url": {
    "value": "https://example.com/videos",
    "is_set": true,
    "hint": "Currently configured"
  },
  "telegram_channel_id": {
    "value": "@mychannel",
    "is_set": true,
    "hint": "Currently configured"
  },
  "telegram_bot_token": {
    "value": null,
    "is_set": true,
    "hint": "Set (value withheld for security)"
  }
}
```

**Example Response (missing variables):**
```json
{
  "monitored_video_page_url": {
    "value": null,
    "is_set": false,
    "hint": "Not set — update server .env file"
  },
  "telegram_channel_id": {
    "value": null,
    "is_set": false,
    "hint": "Not set — update server .env file"
  },
  "telegram_bot_token": {
    "value": null,
    "is_set": false,
    "hint": "Not set — update server .env file"
  }
}
```