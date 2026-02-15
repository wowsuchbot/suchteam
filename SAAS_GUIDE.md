# SaaS Implementation Guide

This document outlines the SaaS transformation of Suchteam from a personal orchestrator to a multi-tenant subscription service.

## Overview

The SaaS version adds:
- User authentication and authorization
- Multi-tenant organization structure
- Subscription management (Free/Pro/Enterprise)
- API key authentication
- Usage tracking and rate limiting
- Billing integration structure

## Architecture

### Data Model

```
Users
  ├─ Organizations (via OrganizationMembers)
  │   ├─ Teams
  │   │   └─ Agents
  │   │       └─ Tasks
  │   ├─ Subscription
  │   ├─ API Keys
  │   └─ Usage Records
  └─ User Tokens (sessions)
```

### Key Components

1. **Accounts Context** (`lib/suchteam/accounts.ex`)
   - User registration and authentication
   - Session management
   - Password hashing with bcrypt

2. **Organizations Context** (`lib/suchteam/organizations.ex`)
   - Multi-tenant organization management
   - Member roles (owner, admin, member)
   - API key generation and validation

3. **Billing Context** (`lib/suchteam/billing.ex`)
   - Subscription plan management
   - Usage tracking
   - Limit enforcement

4. **Authentication Plugs**
   - `UserAuth`: Web session authentication
   - `ApiAuth`: API key authentication

## Setup Instructions

### 1. Run Database Migrations

```bash
mix ecto.migrate
```

This creates tables for:
- `users` and `users_tokens`
- `organizations` and `organization_members`
- `subscriptions` and `usage_records`
- `api_keys`

### 2. Update Team Records

Existing teams need to be associated with organizations:

```elixir
# In IEx or seeds
alias Suchteam.{Repo, Accounts, Organizations}
alias Suchteam.Agents.Team

# Create a default admin user
{:ok, admin} = Accounts.register_user(%{
  email: "admin@example.com",
  password: "secure_password_123"
})

# Create an organization
{:ok, org} = Organizations.create_organization(admin, %{
  name: "Default Organization"
})

# Link existing teams to the organization
Repo.all(Team)
|> Enum.each(fn team ->
  team
  |> Ecto.Changeset.change(organization_id: org.id)
  |> Repo.update!()
end)
```

### 3. Configure Session Secret

Ensure your `config/runtime.exs` has a strong secret key:

```elixir
config :suchteam, SuchteamWeb.Endpoint,
  secret_key_base: System.get_env("SECRET_KEY_BASE")
```

Generate a secret key:
```bash
mix phx.gen.secret
```

### 4. Enable Authentication

Update `config/dev.exs` or `config/prod.exs` as needed. Authentication is enabled by default.

## Usage

### For End Users

1. **Sign Up**: Visit `/register` to create an account
2. **Create Organization**: Automatically created on registration
3. **Get API Key**: Go to organization dashboard → "New API Key"
4. **Use API**: Include API key in Authorization header

### For Developers

#### Create a User Programmatically

```elixir
alias Suchteam.Accounts

{:ok, user} = Accounts.register_user(%{
  email: "user@example.com",
  password: "secure_password_123"
})
```

#### Create an API Key

```elixir
alias Suchteam.Organizations

{:ok, api_key, plain_key} = Organizations.create_api_key(
  organization_id,
  "My API Key"
)

# Save plain_key securely - it's only shown once!
IO.puts("API Key: #{plain_key}")
```

#### Check Subscription Limits

```elixir
alias Suchteam.Billing

can_create = Billing.can_perform_action?(
  organization_id,
  :create_agent,
  current_agent_count
)

if can_create do
  # Create agent
else
  # Show upgrade prompt
end
```

#### Track Usage

```elixir
alias Suchteam.Billing

# Automatically tracked by API plugs
Billing.record_usage(organization_id, "api_calls", 1)
Billing.record_usage(organization_id, "task_count", 1)
```

## Subscription Plans

### Free Plan
- **Cost**: $0/month
- **Limits**: 5 agents, 100 tasks/day, 100 API calls/hour
- **Best for**: Personal projects, testing

### Pro Plan
- **Cost**: $49/month (suggested)
- **Limits**: 50 agents, 10,000 tasks/day, 1,000 API calls/hour
- **Features**: API access, priority support
- **Best for**: Small teams, production apps

### Enterprise Plan
- **Cost**: Custom pricing
- **Limits**: Unlimited
- **Features**: SLA, custom integrations, dedicated support
- **Best for**: Large organizations

## Security Considerations

### Password Security
- Passwords hashed with bcrypt (cost factor 12)
- Minimum password length: 12 characters
- Session tokens stored as SHA256 hashes

### API Key Security
- Keys prefixed with `sk_live_` or `sk_test_`
- Stored as SHA256 hashes in database
- Plain keys shown only once at creation
- Support for expiration and revocation

### Session Security
- 60-day session expiration
- Secure cookies with SameSite=Lax
- CSRF protection on all forms
- Session renewal on login

### Data Isolation
- All queries filtered by organization_id
- Foreign key constraints ensure referential integrity
- Organizations cannot access other organizations' data

## Billing Integration

### Stripe Integration (Future)

To enable Stripe billing:

1. Add Stripe library:
```elixir
{:stripe, "~> 3.0"}
```

2. Configure in `config/runtime.exs`:
```elixir
config :stripity_stripe,
  api_key: System.get_env("STRIPE_SECRET_KEY"),
  public_key: System.get_env("STRIPE_PUBLIC_KEY")
```

3. Handle webhooks in `lib/suchteam_web/controllers/stripe_webhook_controller.ex`

4. Update subscription when Stripe events received:
```elixir
def handle_subscription_updated(stripe_subscription) do
  subscription = Repo.get_by!(Subscription, 
    stripe_subscription_id: stripe_subscription.id
  )
  
  Billing.update_subscription(subscription, %{
    status: stripe_subscription.status,
    current_period_end: stripe_subscription.current_period_end
  })
end
```

## API Changes

### Authentication Required

All `/api/*` endpoints (except `/api/health`) now require API key:

```bash
curl -H "Authorization: Bearer sk_live_xxx" \
  http://localhost:4000/api/agents
```

### Rate Limiting

Requests exceeding limits return:

```json
{
  "error": "Subscription limit exceeded",
  "plan": "free",
  "limits": {
    "max_api_calls_per_hour": 100
  }
}
```

### Organization Scoping

All resources automatically scoped to the authenticated organization:
- Creating an agent links it to the organization
- Listing agents only shows organization's agents
- Cannot access other organizations' resources

## Testing

### Test User Authentication

```elixir
# test/support/fixtures/accounts_fixtures.ex
def user_fixture(attrs \\ %{}) do
  {:ok, user} =
    attrs
    |> Enum.into(%{
      email: "user#{System.unique_integer()}@example.com",
      password: "secure_password_123"
    })
    |> Suchteam.Accounts.register_user()

  user
end
```

### Test API Authentication

```elixir
test "requires API key" do
  conn = get(conn, "/api/agents")
  assert json_response(conn, 401)["error"] =~ "Missing API key"
end

test "authenticates with valid API key" do
  {plain_key, _} = api_key_fixture()
  
  conn =
    conn
    |> put_req_header("authorization", "Bearer #{plain_key}")
    |> get("/api/agents")
    
  assert json_response(conn, 200)
end
```

## Migration Path

### Migrating Existing Data

If you have existing agents and teams:

1. Create admin user and organization
2. Update all teams with organization_id
3. Agents automatically inherit organization through team relationship
4. Generate API keys for external integrations

### Backward Compatibility

The web interface maintains backward compatibility:
- Existing users can register and claim teams
- Team slugs remain unique globally
- API endpoints work the same way (with authentication)

## Monitoring

### Usage Monitoring

Track organization usage:

```elixir
alias Suchteam.Billing

# Get current month usage
start_date = Date.beginning_of_month(Date.utc_today())
usage = Billing.get_usage_summary(
  organization_id,
  DateTime.new!(start_date, ~T[00:00:00]),
  DateTime.utc_now()
)
```

### API Key Activity

Monitor API key usage:

```elixir
alias Suchteam.Organizations

api_keys = Organizations.list_api_keys(organization_id)

Enum.each(api_keys, fn key ->
  IO.puts "#{key.name}: last used #{key.last_used_at}"
end)
```

## Troubleshooting

### Users Can't Access Their Organizations

Check organization membership:

```elixir
alias Suchteam.Organizations

Organizations.member?(organization, user_id)
```

### API Requests Failing

1. Verify API key is valid and not expired
2. Check organization subscription status
3. Verify usage limits not exceeded

### Subscription Limits Not Working

Ensure `ApiAuth.check_subscription_limits/2` plug is added to routes that need limiting.

## Next Steps

1. **Add Stripe Integration**: Complete payment processing
2. **Email Notifications**: Welcome emails, usage alerts
3. **Admin Dashboard**: System-wide analytics
4. **Audit Logging**: Track all organization changes
5. **SSO Integration**: SAML/OAuth for enterprise
6. **Webhooks**: Allow organizations to receive event notifications
7. **Usage Analytics**: Detailed breakdown by agent/task type

## Support

For questions or issues:
- Check documentation in `/docs`
- Review code in `/lib/suchteam/accounts` and `/lib/suchteam/organizations`
- Open an issue on GitHub
