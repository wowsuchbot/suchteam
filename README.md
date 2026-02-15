# Suchteam - Phoenix Swarm Orchestrator (SaaS Edition)

A Phoenix LiveView-based orchestrator for distributed AI agents with OpenClaw integration. Built as a Phoenix-centric alternative to the TypeScript swarm-conductor, now with multi-tenant SaaS capabilities.

## Features

### Core Features
- **Live Dashboard** - Real-time stats, agent status, OpenClaw connection
- **Agent Management** - Create, monitor, and terminate master/sub agents
- **Task Queue** - Oban-powered async task execution with priorities
- **Chat Interface** - Interact with agents through a chat UI
- **Real-time Updates** - Phoenix Channels + PubSub for instant sync
- **REST API** - Full CRUD API for agents, tasks, health checks
- **File Browser** - Browse local project files in the chat interface

### SaaS Features
- **User Authentication** - Secure login/registration with bcrypt password hashing
- **Multi-Tenancy** - Organization-based isolation for hundreds of users
- **Subscription Management** - Free, Pro, and Enterprise plans with usage limits
- **API Key Management** - Secure API keys per organization
- **Usage Tracking** - Track API calls, tasks, and agent hours
- **Rate Limiting** - Subscription-based limits on API usage
- **Billing Ready** - Stripe integration structure for payments

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Phoenix LiveView                          │
│    Dashboard │ Agents │ Chat │ File Browser                 │
└─────────────────────┬───────────────────────────────────────┘
                      │ LiveView + Channels
┌─────────────────────▼───────────────────────────────────────┐
│              Phoenix Application (Bandit)                    │
│  Orchestrator │ OpenClaw Client │ Oban Queues │ PubSub      │
└─────┬───────────────┬───────────────┬───────────────────────┘
      │               │               │
┌─────▼─────┐  ┌──────▼──────┐  ┌─────▼─────────┐
│ PostgreSQL │  │    Redis    │  │  OpenClaw     │
│ Ecto+Oban  │  │  (optional) │  │  (WebSocket)  │
└───────────┘  └─────────────┘  └───────────────┘
```

## Quick Start

### Prerequisites

- Elixir 1.14+
- PostgreSQL 16
- Node.js 18+ (for asset building)
- Redis (optional, for caching)

### Installation

```bash
# Clone and setup
cd suchteam

# Install dependencies
mix deps.get

# Start PostgreSQL (via Docker)
docker-compose up -d db

# Run migrations
mix ecto.setup

# Start server
mix phx.server
```

Visit [`localhost:4000`](http://localhost:4000)

### With OpenClaw

```bash
# Set environment variables
export OPENCLAW_ENABLED=true
export OPENCLAW_GATEWAY_URL=ws://localhost:18789
export OPENCLAW_GATEWAY_TOKEN=your_token

# Start OpenClaw (if using Docker)
docker-compose --profile openclaw up -d

# Start Phoenix
mix phx.server
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DATABASE_URL` | `ecto://postgres:postgres@localhost:5433/suchteam_dev` | PostgreSQL connection |
| `REDIS_URL` | `redis://localhost:6379` | Redis connection |
| `OPENCLAW_ENABLED` | `false` | Enable OpenClaw integration |
| `OPENCLAW_GATEWAY_URL` | `ws://localhost:18789` | OpenClaw WebSocket URL |
| `OPENCLAW_HTTP_URL` | `http://localhost:18789` | OpenClaw HTTP URL |
| `OPENCLAW_GATEWAY_TOKEN` | `nil` | OpenClaw auth token |
| `PHX_HOST` | `localhost` | Phoenix host |
| `PORT` | `4000` | Server port |
| `SECRET_KEY_BASE` | (required in prod) | Secret key for sessions |

### Config Files

```
config/
├── config.exs      # Base config, OpenClaw defaults
├── dev.exs         # Development settings
├── prod.exs        # Production settings
├── runtime.exs     # Runtime env vars
└── test.exs        # Test settings
```

### Disabling OpenClaw (Development)

OpenClaw is disabled by default. To enable:

```bash
# In .env or shell
export OPENCLAW_ENABLED=true
```

Or in `config/dev.exs`:

```elixir
config :suchteam, :open_claw,
  enabled: true,
  gateway_url: "ws://localhost:18789",
  ...
```

## Project Structure

```
suchteam/
├── config/                    # Configuration
├── lib/
│   ├── suchteam/              # Business logic
│   │   ├── agents.ex          # Agents context
│   │   ├── agents/            # Schemas
│   │   │   ├── agent.ex
│   │   │   ├── task.ex
│   │   │   └── team.ex
│   │   ├── open_claw/         # OpenClaw integration
│   │   │   ├── client.ex      # WebSocket client
│   │   │   ├── http.ex        # HTTP client
│   │   │   └── supervisor.ex
│   │   ├── orchestrator.ex    # Main coordinator
│   │   ├── workers/           # Oban workers
│   │   │   └── task_worker.ex
│   │   └── application.ex
│   └── suchteam_web/          # Web layer
│       ├── channels/          # Phoenix Channels
│       ├── controllers/       # Controllers
│       │   └── api/           # REST API
│       ├── live/              # LiveView
│       │   ├── dashboard_live.ex
│       │   ├── chat_live.ex
│       │   └── agent_live/
│       ├── components/        # Shared components
│       └── router.ex
├── priv/
│   └── repo/migrations/       # Database migrations
├── docker-compose.yml
└── mix.exs
```

## Routes

### Web Interface

| Route | Description |
|-------|-------------|
| `/` | Dashboard with stats |
| `/chat` | Chat interface with file browser |
| `/agents` | Agent list |
| `/agents/:id` | Agent details & task delegation |
| `/dev/dashboard` | LiveDashboard (dev only) |

### REST API

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/health` | System health check |
| GET | `/api/agents` | List all agents |
| POST | `/api/agents` | Create agent |
| GET | `/api/agents/:id` | Get agent |
| DELETE | `/api/agents/:id` | Terminate agent |
| POST | `/api/agents/:id/tasks` | Delegate task |
| GET | `/api/agents/:id/tasks` | List agent tasks |

### WebSocket Channels

```javascript
// Connect
const socket = new Socket("/socket")
socket.connect()

// Join agent channel (team-scoped)
const channel = socket.channel("agents:team-id")
channel.join()

// Events
channel.on("created", agent => {})
channel.on("terminated", agent => {})
channel.on("status_changed", agent => {})
channel.on("task_queued", data => {})
channel.on("task_completed", data => {})

// Orchestrator channel
const orchChannel = socket.channel("orchestrator")
orchChannel.join()
orchChannel.on("openclaw:connected", () => {})
orchChannel.on("openclaw:disconnected", () => {})
```

## Core Concepts

### Agents

```elixir
# Create via Orchestrator
{:ok, agent} = Suchteam.Orchestrator.create_agent(%{
  team_id: "team-123",
  type: "master"  # or "sub"
})

# Types:
# - master: Primary agent, receives top-level commands
# - sub: Spawned by master for specialized tasks

# Statuses:
# - idle: Waiting for tasks
# - active: Currently processing
# - terminated: Stopped
```

### Tasks

```elixir
# Delegate task to agent
{:ok, task} = Suchteam.Orchestrator.delegate_task(agent_id, %{
  "text" => "Analyze this data"
}, priority: 1)

# Priorities: 1 (highest) to 10 (lowest)

# Task statuses:
# - pending: Queued
# - running: Being processed
# - completed: Success
# - failed: Error occurred
```

### Orchestrator

The central GenServer coordinating all operations:

```elixir
Suchteam.Orchestrator.create_agent(attrs)
Suchteam.Orchestrator.get_agent(id)
Suchteam.Orchestrator.list_agents(team_id)
Suchteam.Orchestrator.delegate_task(agent_id, payload, opts)
Suchteam.Orchestrator.terminate_agent(agent_id)
Suchteam.Orchestrator.get_stats()
```

## Docker

```bash
# Start PostgreSQL + Redis
docker-compose up -d

# With OpenClaw
docker-compose --profile openclaw up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down
```

## Development

```bash
# Start interactive shell
iex -S mix phx.server

# Run tests
mix test

# Format code
mix format

# Check credo (if installed)
mix credo

# Database
mix ecto.create
mix ecto.migrate
mix ecto.reset  # Drop, create, migrate, seed
```

## SaaS Features

### Authentication & Multi-Tenancy

Suchteam now supports multiple users and organizations with secure authentication:

1. **User Registration**: Users create accounts with email/password
2. **Organizations**: Each user can create/join multiple organizations
3. **Team Isolation**: Teams belong to organizations, ensuring data isolation
4. **Role-Based Access**: Owner, Admin, and Member roles per organization

### Subscription Plans

| Plan | Max Agents | Max Tasks/Day | API Calls/Hour | Features |
|------|-----------|---------------|----------------|----------|
| **Free** | 5 | 100 | 100 | Basic agents, Web interface |
| **Pro** | 50 | 10,000 | 1,000 | + API access, Priority support |
| **Enterprise** | Unlimited | Unlimited | Unlimited | + SLA, Custom integrations |

### API Authentication

All API requests require authentication via API keys:

```bash
# Create an API key in the organization dashboard
# Use it in requests:
curl -H "Authorization: Bearer sk_live_..." \
  http://localhost:4000/api/agents
```

### Usage Tracking

The system tracks:
- **API Calls**: Number of API requests per hour
- **Task Count**: Number of tasks executed per day
- **Agent Hours**: Total agent runtime hours

View usage in your organization dashboard at `/organizations/:id`

### Rate Limiting

Subscription-based rate limiting enforces plan limits:
- Free tier: 100 API calls/hour
- Pro tier: 1,000 API calls/hour
- Enterprise: No limits

Exceeded limits return HTTP 403 with upgrade instructions.

## Comparison with TypeScript Version

| Feature | TypeScript (swarm-conductor) | Elixir (suchteam) |
|---------|------------------------------|-------------------|
| Runtime | Node.js | BEAM VM |
| Framework | Express | Phoenix |
| WebSockets | Socket.IO | Phoenix Channels |
| Real-time UI | React + polling | LiveView |
| Job Queue | BullMQ + Redis | Oban + PostgreSQL |
| Fault Tolerance | Manual | Supervisor trees |
| Hot Reload | Restart required | Hot code swap |

## License

MIT
