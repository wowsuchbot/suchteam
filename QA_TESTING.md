# Manual QA Testing Guide

This document outlines the manual testing procedures for all features in the Suchteam application.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Authentication](#authentication)
3. [Organization Management](#organization-management)
4. [Subscription & Billing](#subscription--billing)
5. [API Key Management](#api-key-management)
6. [Agent Management](#agent-management)
7. [Chat Interface](#chat-interface)
8. [REST API](#rest-api)
9. [Dashboard](#dashboard)
10. [Real-time Features](#real-time-features)

---

## Prerequisites

Before testing, ensure you have:
- [ ] Application running locally (`mix phx.server`)
- [ ] Database set up (`mix ecto.setup`)
- [ ] At least two browser windows/tabs for real-time testing
- [ ] API testing tool (curl, Postman, or similar)

**Test Accounts Needed:**
- Create at least 2 test user accounts
- One account should belong to multiple organizations

---

## Authentication

### REG-001: User Registration
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to `/register` | Registration form displays |
| 2 | Enter email: `test@example.com` | Field accepts input |
| 3 | Enter password: `password123` (11 chars) | Field accepts input |
| 4 | Click "Create Account" | Error: "Password must be at least 12 characters" |
| 5 | Enter password: `password1234` (12 chars) | Field accepts input |
| 6 | Enter organization name: `Test Org` (optional) | Field accepts input |
| 7 | Click "Create Account" | Account created, redirected to dashboard |
| 8 | Verify organization created | Organization "Test Org" appears in org list |

**Pass/Fail:** ___

### REG-002: Registration Validation - Invalid Email
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to `/register` | Registration form displays |
| 2 | Enter email: `invalid-email` | Field accepts input |
| 3 | Enter valid password (12+ chars) | Field accepts input |
| 4 | Click "Create Account" | Error: "must have the @ sign" or similar |

**Pass/Fail:** ___

### REG-003: Registration Validation - Duplicate Email
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Register with email `existing@example.com` | Account created |
| 2 | Navigate to `/register` again | Registration form displays |
| 3 | Enter same email `existing@example.com` | Field accepts input |
| 4 | Enter valid password | Field accepts input |
| 5 | Click "Create Account" | Error: "Email already in use" or similar |

**Pass/Fail:** ___

### LOG-001: Login Success
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to `/login` | Login form displays |
| 2 | Enter valid email | Field accepts input |
| 3 | Enter valid password | Field accepts input |
| 4 | Click "Sign In" | Redirected to dashboard (`/`) |

**Pass/Fail:** ___

### LOG-002: Login Failure - Wrong Password
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to `/login` | Login form displays |
| 2 | Enter valid email | Field accepts input |
| 3 | Enter incorrect password | Field accepts input |
| 4 | Click "Sign In" | Error: "Invalid email or password" |

**Pass/Fail:** ___

### LOG-003: Login Failure - Non-existent Email
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to `/login` | Login form displays |
| 2 | Enter email: `nonexistent@example.com` | Field accepts input |
| 3 | Enter any password | Field accepts input |
| 4 | Click "Sign In" | Error: "Invalid email or password" (same error as wrong password) |

**Pass/Fail:** ___

### LOG-004: Remember Me / Session Persistence
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to `/login` | Login form displays |
| 2 | Check "Keep me logged in" checkbox | Checkbox checked |
| 3 | Enter credentials and sign in | Redirected to dashboard |
| 4 | Close browser completely | Browser closed |
| 5 | Reopen browser and navigate to app | Still logged in, dashboard displayed |

**Pass/Fail:** ___

### LOG-005: Logout
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Be logged in | Dashboard visible |
| 2 | Click "Logout" or navigate to `/logout` | Session destroyed |
| 3 | Verify redirect | Redirected to login page |

**Pass/Fail:** ___

### LOG-006: Unauthenticated Access Prevention
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Logout if logged in | On login page |
| 2 | Navigate to `/` | Redirected to `/login` |
| 3 | Navigate to `/agents` | Redirected to `/login` |
| 4 | Navigate to `/chat` | Redirected to `/login` |
| 5 | Navigate to `/organizations` | Redirected to `/login` |

**Pass/Fail:** ___

---

## Organization Management

### ORG-001: View Organizations List
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Login with test account | Dashboard displayed |
| 2 | Navigate to `/organizations` | Organizations list page displays |
| 3 | Verify organizations shown | All user's organizations listed with plan badges |

**Pass/Fail:** ___

### ORG-002: Create Organization
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to `/organizations` | Organizations list displays |
| 2 | Click "New Organization" or navigate to `/organizations/new` | New organization form displays |
| 3 | Enter name: `New Test Org` | Field accepts input |
| 4 | Enter slug: `new-test-org` | Field accepts input |
| 5 | Click "Create Organization" | Organization created, redirected to org dashboard |
| 6 | Navigate to `/organizations` | New organization appears in list |

**Pass/Fail:** ___

### ORG-003: Create Organization - Auto-generated Slug
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to `/organizations/new` | New organization form displays |
| 2 | Enter name: `Auto Slug Test` | Field accepts input |
| 3 | Leave slug field empty | Field remains empty |
| 4 | Click "Create Organization" | Organization created with slug `auto-slug-test` |

**Pass/Fail:** ___

### ORG-004: Create Organization - Duplicate Slug
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Create org with slug `duplicate-test` | Organization created |
| 2 | Navigate to `/organizations/new` | New organization form displays |
| 3 | Enter different name, slug: `duplicate-test` | Field accepts input |
| 4 | Click "Create Organization" | Error: "Slug already taken" or similar |

**Pass/Fail:** ___

### ORG-005: View Organization Dashboard
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to `/organizations` | Organizations list displays |
| 2 | Click on an organization name | Organization dashboard displays |
| 3 | Verify displayed information | Shows: subscription info, usage stats, API keys list |

**Pass/Fail:** ___

### ORG-006: Edit Organization Settings
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to organization dashboard | Dashboard displays |
| 2 | Click "Settings" or navigate to `/organizations/:id/settings` | Settings form displays |
| 3 | Change organization name | Field accepts new value |
| 4 | Click "Save" | Changes saved, success message shown |
| 5 | Navigate back to org list | Updated name displayed |

**Pass/Fail:** ___

### ORG-007: Delete Organization (Danger Zone)
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to organization settings | Settings form displays |
| 2 | Scroll to "Danger Zone" | Danger zone section visible |
| 3 | Click "Delete Organization" | Confirmation prompt appears |
| 4 | Confirm deletion | Organization deleted, redirected to org list |
| 5 | Verify org not in list | Organization no longer appears |

**Pass/Fail:** ___

---

## Subscription & Billing

### SUB-001: Free Tier Default on Registration
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Register new account | Account created |
| 2 | Navigate to organization dashboard | Dashboard displays |
| 3 | Check subscription status | Shows "Free Plan" badge |

**Pass/Fail:** ___

### SUB-002: Usage Stats Display
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to organization dashboard | Dashboard displays |
| 2 | Verify usage section | Shows: API calls count, tasks count, agent hours |
| 3 | Create an agent via API | API call count increases |
| 4 | Delegate a task | Task count increases |
| 5 | Refresh dashboard | Updated stats displayed |

**Pass/Fail:** ___

### SUB-003: Agent Limit Enforcement (Free Tier - 5 agents max)
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Create 5 agents | All 5 created successfully |
| 2 | Attempt to create 6th agent | Error: "Agent limit exceeded. Upgrade to Pro for more agents." |

**Pass/Fail:** ___

### SUB-004: Task Limit Enforcement (Free Tier - 100 tasks/day)
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Create tasks until reaching limit (or simulate) | Tasks created successfully |
| 2 | Attempt to create task after limit | Error: "Daily task limit exceeded. Upgrade to Pro." |

**Pass/Fail:** ___

### SUB-005: API Rate Limiting (Free Tier - 100 calls/hour)
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Make API calls until approaching limit | All calls succeed |
| 2 | Make call after limit exceeded | 403 Forbidden with upgrade prompt |

**Pass/Fail:** ___

---

## API Key Management

### KEY-001: View API Keys
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to organization dashboard | Dashboard displays |
| 2 | Locate API keys section | List of API keys displayed |
| 3 | Verify key information | Shows: key name, prefix, created date, status |

**Pass/Fail:** ___

### KEY-002: Create API Key
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to organization dashboard | Dashboard displays |
| 2 | Click "New API Key" | API key creation form/modal displays |
| 3 | Enter key name: `Test Key` | Field accepts input |
| 4 | Click "Create" | Key created, full key displayed ONCE |
| 5 | Copy the full key | Key copied to clipboard |
| 6 | Refresh page | Only key prefix shown (e.g., `sk_live_abc...`) |

**Pass/Fail:** ___

### KEY-003: API Key Authentication
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Create API key and copy full key | Key obtained |
| 2 | Make API request: `curl -H "Authorization: Bearer YOUR_KEY" http://localhost:4000/api/agents` | 200 OK with agents list |

**Pass/Fail:** ___

### KEY-004: Invalid API Key
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Make API request with invalid key: `curl -H "Authorization: Bearer invalid_key" http://localhost:4000/api/agents` | 401 Unauthorized |

**Pass/Fail:** ___

### KEY-005: Revoke API Key
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Create API key | Key created |
| 2 | Test key works | Request succeeds |
| 3 | Navigate to org dashboard, click "Revoke" on key | Key revoked |
| 4 | Test same key again | 401 Unauthorized |

**Pass/Fail:** ___

---

## Agent Management

### AGT-001: View Agents List
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Login and navigate to `/agents` | Agents list page displays |
| 2 | Verify table columns | Shows: ID, Type, Status, Session Key, Last Ping, Actions |
| 3 | Verify agents listed | All organization's agents displayed |

**Pass/Fail:** ___

### AGT-002: Create Master Agent
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to `/agents` | Agents list displays |
| 2 | Click "Create Agent" or navigate to `/agents/new` | Agent creation page displays |
| 3 | Select "Master" agent type | Master type selected |
| 4 | Click "Create" | Agent created, redirected to agent details |
| 5 | Verify status | Status shows "idle" |

**Pass/Fail:** ___

### AGT-003: Create Sub Agent
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to `/agents/new` | Agent creation page displays |
| 2 | Select "Sub" agent type | Sub type selected |
| 3 | Click "Create" | Agent created, redirected to agent details |
| 4 | Verify status | Status shows "idle" |

**Pass/Fail:** ___

### AGT-004: View Agent Details
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to `/agents` | Agents list displays |
| 2 | Click on an agent ID | Agent details page displays |
| 3 | Verify displayed information | Shows: Type, Status, Session Key, Created timestamp, Task delegation form, Task history |

**Pass/Fail:** ___

### AGT-005: Delegate Task to Agent
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to agent details page | Agent details displayed |
| 2 | Enter task text: "Review the main module and suggest improvements" | Field accepts input |
| 3 | Click "Send Task" | Task queued, appears in task history |
| 4 | Verify task status | Task shows as "queued" or "processing" |
| 5 | Wait for task completion | Task status changes to "completed" |

**Pass/Fail:** ___

### AGT-006: Delegate Task - Empty Text
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to agent details page | Agent details displayed |
| 2 | Leave task text field empty | Field remains empty |
| 3 | Click "Send Task" | Error: "Task text cannot be empty" |

**Pass/Fail:** ___

### AGT-007: Terminate Agent
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to agent details page (active agent) | Agent details displayed |
| 2 | Click "Terminate" button | Confirmation appears (if applicable) |
| 3 | Confirm termination | Agent status changes to "terminated" |
| 4 | Navigate to agents list | Agent shows "terminated" status |

**Pass/Fail:** ___

### AGT-008: Delegate to Terminated Agent
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to terminated agent's details | Agent details displayed |
| 2 | Enter task text | Field accepts input |
| 3 | Click "Send Task" | Error: "Cannot delegate task to terminated agent" |

**Pass/Fail:** ___

### AGT-009: Agent Status Transitions
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Create new agent | Status: "idle" |
| 2 | Send task to agent | Status: "busy" or "working" |
| 3 | Task completes | Status: "idle" |
| 4 | Terminate agent | Status: "terminated" |

**Pass/Fail:** ___

---

## Chat Interface

### CHAT-001: View Chat Interface
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to `/chat` | Chat interface displays |
| 2 | Verify layout | Shows: message area, input form, file browser sidebar, agent selector panel |

**Pass/Fail:** ___

### CHAT-002: File Browser - Navigate Directories
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to `/chat` | Chat interface displays |
| 2 | Locate file browser panel | File tree visible |
| 3 | Click on a directory folder | Directory expands, shows contents |
| 4 | Click on file | File selected or contents previewed |

**Pass/Fail:** ___

### CHAT-003: File Browser - Refresh
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Create a new file in the project directory | File created externally |
| 2 | Click refresh button in file browser | File tree refreshes |
| 3 | Verify new file appears | New file visible in tree |

**Pass/Fail:** ___

### CHAT-004: Select Agent
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to `/chat` | Chat interface displays |
| 2 | Locate agent selector panel | Agent list visible |
| 3 | Click on an agent | Agent selected, highlighted |
| 4 | Verify input enabled | Message input field enabled |

**Pass/Fail:** ___

### CHAT-005: Send Message
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Select an agent | Agent selected |
| 2 | Type message: "Hello, can you help me?" | Field accepts input |
| 3 | Click "Send" or press Enter | Message sent, appears in chat area |
| 4 | Verify message attribution | Message shows as from "You" or user's email |

**Pass/Fail:** ___

### CHAT-006: Receive Response
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Send a message to active agent | Message sent |
| 2 | Wait for agent response | Response appears from "Assistant" or agent name |
| 3 | Verify response content | Response is relevant to the message |

**Pass/Fail:** ___

### CHAT-007: No Agent Selected
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to `/chat` without selecting agent | Chat interface displays |
| 2 | Verify input state | Send button disabled or message prompts to select agent |

**Pass/Fail:** ___

---

## REST API

### API-001: Health Check (No Auth)
```bash
curl http://localhost:4000/api/health
```
| Expected Result | Status |
|-----------------|--------|
| 200 OK | |
| Response: `{"status": "ok"}` | |

**Pass/Fail:** ___

### API-002: List Agents
```bash
curl -H "Authorization: Bearer YOUR_API_KEY" http://localhost:4000/api/agents
```
| Expected Result | Status |
|-----------------|--------|
| 200 OK | |
| JSON array of agents | |
| Each agent has: id, type, status, session_key, timestamps | |

**Pass/Fail:** ___

### API-003: Create Agent
```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"agent": {"type": "master"}}' \
  http://localhost:4000/api/agents
```
| Expected Result | Status |
|-----------------|--------|
| 201 Created | |
| Response contains new agent object | |
| Agent has generated ID and session_key | |

**Pass/Fail:** ___

### API-004: Get Agent by ID
```bash
curl -H "Authorization: Bearer YOUR_API_KEY" http://localhost:4000/api/agents/AGENT_ID
```
| Expected Result | Status |
|-----------------|--------|
| 200 OK | |
| Response contains agent details | |

**Pass/Fail:** ___

### API-005: Delete/Terminate Agent
```bash
curl -X DELETE \
  -H "Authorization: Bearer YOUR_API_KEY" \
  http://localhost:4000/api/agents/AGENT_ID
```
| Expected Result | Status |
|-----------------|--------|
| 200 OK | |
| Response contains terminated agent | |
| Agent status is "terminated" | |

**Pass/Fail:** ___

### API-006: Delegate Task to Agent
```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"task": {"text": "Analyze the codebase structure"}}' \
  http://localhost:4000/api/agents/AGENT_ID/tasks
```
| Expected Result | Status |
|-----------------|--------|
| 200 OK | |
| Response contains task object | |
| Task has id, text, status: "queued" | |

**Pass/Fail:** ___

### API-007: List Agent Tasks
```bash
curl -H "Authorization: Bearer YOUR_API_KEY" http://localhost:4000/api/agents/AGENT_ID/tasks
```
| Expected Result | Status |
|-----------------|--------|
| 200 OK | |
| JSON array of tasks | |
| Tasks ordered by creation date (newest first) | |

**Pass/Fail:** ___

### API-008: Cross-Organization Access Prevention
```bash
# Use API key from Org A to access Agent from Org B
curl -H "Authorization: Bearer ORG_A_API_KEY" http://localhost:4000/api/agents/ORG_B_AGENT_ID
```
| Expected Result | Status |
|-----------------|--------|
| 403 Forbidden | |
| Error message about access denied | |

**Pass/Fail:** ___

### API-009: Missing Authorization Header
```bash
curl http://localhost:4000/api/agents
```
| Expected Result | Status |
|-----------------|--------|
| 401 Unauthorized | |
| Error: "Missing API key" | |

**Pass/Fail:** ___

### API-010: Invalid API Key Format
```bash
curl -H "Authorization: Bearer not_a_valid_key" http://localhost:4000/api/agents
```
| Expected Result | Status |
|-----------------|--------|
| 401 Unauthorized | |
| Error: "Invalid API key" | |

**Pass/Fail:** ___

---

## Dashboard

### DASH-001: View Dashboard Stats
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Login and navigate to `/` | Dashboard displays |
| 2 | Verify stats cards | Shows: Total agents, Active agents, Idle agents, Terminated agents |
| 3 | Verify counts are accurate | Counts match actual agent states |

**Pass/Fail:** ___

### DASH-002: OpenClaw Connection Status
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to `/` | Dashboard displays |
| 2 | Locate OpenClaw status indicator | Status badge visible |
| 3 | Verify status display | Shows "Connected" (green) or "Disconnected" (red/gray) |

**Pass/Fail:** ___

### DASH-003: Dashboard Navigation
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Click "Open Chat" button | Navigates to `/chat` |
| 2 | Navigate back to `/` | Dashboard displays |
| 3 | Click "Manage Agents" button | Navigates to `/agents` |
| 4 | Navigate back to `/` | Dashboard displays |

**Pass/Fail:** ___

### DASH-004: Real-time Dashboard Updates
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Open dashboard in two browser tabs | Both show same stats |
| 2 | In Tab 1: Create a new agent | Agent created |
| 3 | Check Tab 2 (without refresh) | Total agents count increased |
| 4 | In Tab 1: Terminate an agent | Agent terminated |
| 5 | Check Tab 2 | Terminated count increased |

**Pass/Fail:** ___

---

## Real-time Features

### RT-001: Agent List Real-time Updates
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Open `/agents` in two browser tabs | Both show same agent list |
| 2 | In Tab 1: Create new agent | Agent appears in list |
| 3 | Check Tab 2 immediately | New agent appears without refresh |
| 4 | In Tab 1: Terminate agent | Agent status changes |
| 5 | Check Tab 2 immediately | Status change reflected |

**Pass/Fail:** ___

### RT-002: Chat Real-time Updates
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Open `/chat` in two browser tabs | Both show same chat state |
| 2 | In Tab 1: Send message | Message appears |
| 3 | Check Tab 2 immediately | Message appears in Tab 2 |

**Pass/Fail:** ___

### RT-003: Organization Real-time Updates
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Open org dashboard in two tabs | Both show same info |
| 2 | In Tab 1: Create API key | Key created |
| 3 | Check Tab 2 immediately | New key appears in list |

**Pass/Fail:** ___

---

## Edge Cases & Error Handling

### ERR-001: Session Expiry
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Login and wait for session to expire | Session expires |
| 2 | Attempt any action | Redirected to login with session expired message |

**Pass/Fail:** ___

### ERR-002: Concurrent Task Delegation
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Open agent details in two tabs | Both tabs open |
| 2 | In both tabs: Send different tasks simultaneously | Both tasks queued or one rejected appropriately |

**Pass/Fail:** ___

### ERR-003: Network Interruption
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Open dashboard | Dashboard displays |
| 2 | Disconnect network | Network disconnected |
| 3 | Wait 30 seconds | Error message or reconnection attempt shown |
| 4 | Reconnect network | Real-time connection restored |

**Pass/Fail:** ___

### ERR-004: Invalid Form Input
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to registration | Form displays |
| 2 | Submit form with empty fields | Validation errors shown for required fields |
| 3 | Enter SQL injection attempt in name field | Input sanitized, no error |

**Pass/Fail:** ___

---

## Browser Compatibility

Test the following in each browser:

| Feature | Chrome | Firefox | Safari | Edge |
|---------|--------|---------|--------|------|
| Login/Logout | | | | |
| Real-time updates | | | | |
| File browser | | | | |
| Chat interface | | | | |
| API key display | | | | |

---

## Mobile Responsiveness (Optional)

| Page | Mobile Layout OK? | Notes |
|------|-------------------|-------|
| Login | | |
| Register | | |
| Dashboard | | |
| Agents List | | |
| Agent Details | | |
| Chat | | |
| Organizations | | |

---

## Test Summary

| Category | Total Tests | Passed | Failed | Blocked |
|----------|-------------|--------|--------|---------|
| Authentication | 9 | | | |
| Organization | 7 | | | |
| Subscription | 5 | | | |
| API Keys | 5 | | | |
| Agents | 9 | | | |
| Chat | 7 | | | |
| REST API | 10 | | | |
| Dashboard | 4 | | | |
| Real-time | 3 | | | |
| Error Handling | 4 | | | |
| **TOTAL** | **63** | | | |

---

## Bug Report Template

When a test fails, document with:

```
**Test ID:** [e.g., AGT-005]
**Summary:** [Brief description of the issue]
**Steps to Reproduce:**
1.
2.
3.

**Expected Result:**
**Actual Result:**
**Screenshots:**
**Environment:** [Browser, OS]
**Severity:** [Critical / High / Medium / Low]
```

---

*Document Version: 1.0*
*Last Updated: February 2026*
