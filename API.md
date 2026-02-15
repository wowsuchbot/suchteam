# API Documentation

## Authentication

All API requests require an API key. Include it in the `Authorization` header:

```bash
Authorization: Bearer sk_live_your_api_key_here
```

### Getting an API Key

1. Log in to the web interface
2. Navigate to your organization dashboard
3. Click "New API Key"
4. Copy and save the key (it's only shown once)

## Rate Limiting

API requests are rate-limited based on your subscription plan:

| Plan | API Calls per Hour |
|------|-------------------|
| Free | 100 |
| Pro | 1,000 |
| Enterprise | Unlimited |

When you exceed the limit, you'll receive a `403 Forbidden` response with details about your current plan and limits.

## Endpoints

### Health Check

```http
GET /api/health
```

**Public endpoint** - No authentication required.

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2024-02-15T12:00:00Z"
}
```

### List Agents

```http
GET /api/agents
```

List all agents belonging to your organization.

**Query Parameters:**
- `team_id` (optional): Filter by team ID
- `status` (optional): Filter by status (`idle`, `active`, `terminated`)

**Response:**
```json
{
  "success": true,
  "agents": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "team_id": "660e8400-e29b-41d4-a716-446655440001",
      "type": "master",
      "status": "idle",
      "session_key": "abc123def456",
      "parent_agent_id": null,
      "metadata": {},
      "last_ping_at": "2024-02-15T12:00:00Z",
      "inserted_at": "2024-02-15T10:00:00Z",
      "updated_at": "2024-02-15T12:00:00Z"
    }
  ],
  "count": 1
}
```

### Get Agent

```http
GET /api/agents/:id
```

Get details of a specific agent.

**Response:**
```json
{
  "success": true,
  "agent": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "team_id": "660e8400-e29b-41d4-a716-446655440001",
    "type": "master",
    "status": "idle",
    "session_key": "abc123def456",
    "metadata": {},
    "inserted_at": "2024-02-15T10:00:00Z"
  }
}
```

**Error Responses:**
- `404 Not Found`: Agent doesn't exist
- `403 Forbidden`: Agent doesn't belong to your organization

### Create Agent

```http
POST /api/agents
```

Create a new agent.

**Request Body:**
```json
{
  "team_id": "660e8400-e29b-41d4-a716-446655440001",
  "type": "master",
  "parent_agent_id": null,
  "metadata": {
    "role": "coordinator"
  }
}
```

**Response:**
```json
{
  "success": true,
  "agent": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "team_id": "660e8400-e29b-41d4-a716-446655440001",
    "type": "master",
    "status": "idle",
    "session_key": "abc123def456",
    "inserted_at": "2024-02-15T10:00:00Z"
  }
}
```

**Error Responses:**
- `400 Bad Request`: Invalid parameters or team doesn't belong to your organization
- `403 Forbidden`: Agent limit exceeded for your subscription plan

**Subscription Limits:**
- Free: 5 agents max
- Pro: 50 agents max
- Enterprise: Unlimited

### Delete Agent

```http
DELETE /api/agents/:id
```

Terminate an agent.

**Response:**
```json
{
  "success": true,
  "agent": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "status": "terminated"
  }
}
```

**Error Responses:**
- `404 Not Found`: Agent doesn't exist
- `403 Forbidden`: Agent doesn't belong to your organization

### Delegate Task

```http
POST /api/agents/:id/tasks
```

Delegate a task to an agent.

**Request Body:**
```json
{
  "task": "Analyze the data and generate a report",
  "priority": 1
}
```

- `task` (required): Task description
- `priority` (optional): Priority level 1-10 (1 = highest, default = 5)

**Response:**
```json
{
  "success": true,
  "task": {
    "id": "770e8400-e29b-41d4-a716-446655440002",
    "agent_id": "550e8400-e29b-41d4-a716-446655440000",
    "status": "pending",
    "priority": 1,
    "payload": {
      "text": "Analyze the data and generate a report"
    },
    "inserted_at": "2024-02-15T12:00:00Z"
  }
}
```

**Error Responses:**
- `404 Not Found`: Agent doesn't exist
- `403 Forbidden`: Agent doesn't belong to your organization or daily task limit exceeded
- `400 Bad Request`: Agent is terminated

**Subscription Limits:**
- Free: 100 tasks/day
- Pro: 10,000 tasks/day
- Enterprise: Unlimited

### List Agent Tasks

```http
GET /api/agents/:id/tasks
```

List all tasks for a specific agent.

**Response:**
```json
{
  "success": true,
  "tasks": [
    {
      "id": "770e8400-e29b-41d4-a716-446655440002",
      "agent_id": "550e8400-e29b-41d4-a716-446655440000",
      "status": "completed",
      "priority": 1,
      "payload": {
        "text": "Analyze the data and generate a report"
      },
      "result": {
        "summary": "Analysis complete"
      },
      "started_at": "2024-02-15T12:00:00Z",
      "completed_at": "2024-02-15T12:05:00Z",
      "inserted_at": "2024-02-15T12:00:00Z"
    }
  ],
  "count": 1
}
```

## Error Responses

All error responses follow this format:

```json
{
  "success": false,
  "error": "Error message here"
}
```

Common HTTP status codes:
- `400 Bad Request`: Invalid request parameters
- `401 Unauthorized`: Missing or invalid API key
- `403 Forbidden`: Subscription limit exceeded or access denied
- `404 Not Found`: Resource not found
- `500 Internal Server Error`: Server error

### Subscription Limit Exceeded

When you exceed your subscription limits:

```json
{
  "success": false,
  "error": "Agent limit exceeded",
  "plan": "free",
  "limits": {
    "max_agents": 5,
    "max_tasks_per_day": 100,
    "max_api_calls_per_hour": 100,
    "features": ["basic_agents", "web_interface"]
  }
}
```

## Usage Examples

### cURL

```bash
# List agents
curl -H "Authorization: Bearer sk_live_xxx" \
  https://api.suchteam.dev/api/agents

# Create an agent
curl -X POST \
  -H "Authorization: Bearer sk_live_xxx" \
  -H "Content-Type: application/json" \
  -d '{"team_id":"660e8400-e29b-41d4-a716-446655440001","type":"master"}' \
  https://api.suchteam.dev/api/agents

# Delegate a task
curl -X POST \
  -H "Authorization: Bearer sk_live_xxx" \
  -H "Content-Type: application/json" \
  -d '{"task":"Process the data","priority":1}' \
  https://api.suchteam.dev/api/agents/550e8400-e29b-41d4-a716-446655440000/tasks
```

### Python

```python
import requests

API_KEY = "sk_live_xxx"
BASE_URL = "https://api.suchteam.dev"

headers = {
    "Authorization": f"Bearer {API_KEY}",
    "Content-Type": "application/json"
}

# List agents
response = requests.get(f"{BASE_URL}/api/agents", headers=headers)
agents = response.json()["agents"]

# Create an agent
response = requests.post(
    f"{BASE_URL}/api/agents",
    headers=headers,
    json={
        "team_id": "660e8400-e29b-41d4-a716-446655440001",
        "type": "master"
    }
)
agent = response.json()["agent"]

# Delegate a task
response = requests.post(
    f"{BASE_URL}/api/agents/{agent['id']}/tasks",
    headers=headers,
    json={
        "task": "Process the data",
        "priority": 1
    }
)
task = response.json()["task"]
```

### JavaScript/Node.js

```javascript
const API_KEY = "sk_live_xxx";
const BASE_URL = "https://api.suchteam.dev";

const headers = {
  "Authorization": `Bearer ${API_KEY}`,
  "Content-Type": "application/json"
};

// List agents
const response = await fetch(`${BASE_URL}/api/agents`, { headers });
const { agents } = await response.json();

// Create an agent
const createResponse = await fetch(`${BASE_URL}/api/agents`, {
  method: "POST",
  headers,
  body: JSON.stringify({
    team_id: "660e8400-e29b-41d4-a716-446655440001",
    type: "master"
  })
});
const { agent } = await createResponse.json();

// Delegate a task
const taskResponse = await fetch(`${BASE_URL}/api/agents/${agent.id}/tasks`, {
  method: "POST",
  headers,
  body: JSON.stringify({
    task: "Process the data",
    priority: 1
  })
});
const { task } = await taskResponse.json();
```

## Webhooks (Coming Soon)

Future releases will support webhooks for real-time event notifications:
- `agent.created`
- `agent.terminated`
- `task.queued`
- `task.completed`
- `task.failed`

## Support

For API support:
- Check the [SaaS Guide](./SAAS_GUIDE.md)
- Open an issue on GitHub
- Contact support@suchteam.dev
