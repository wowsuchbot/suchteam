# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Suchteam.Repo.insert!(%Suchteam.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Suchteam.{Repo, Accounts, Organizations, Agents}
alias Suchteam.Organizations.Organization
alias Suchteam.Agents.Team

# ⚠️  WARNING: This creates a demo account with a public password.
# This is for DEVELOPMENT and TESTING only!
# DO NOT run this in production, or change the password immediately after.

# Create or get demo user
IO.puts("Creating demo user...")
user =
  case Accounts.register_user(%{
    email: "demo@suchteam.dev",
    password: "demo_password_123"  # ⚠️  DEMO PASSWORD - NOT FOR PRODUCTION!
  }) do
    {:ok, u} ->
      IO.puts("✓ Demo user created: demo@suchteam.dev")
      u
    {:error, _} ->
      user = Accounts.get_user_by_email("demo@suchteam.dev")
      IO.puts("✓ Demo user already exists: demo@suchteam.dev")
      user
  end

# Create or get demo organization
IO.puts("Creating demo organization...")
org =
  case Organizations.create_organization(user, %{
    name: "Demo Organization",
    slug: "demo-org"
  }) do
    {:ok, o} ->
      IO.puts("✓ Demo organization created: #{o.name}")
      o
    {:error, _} ->
      o = Repo.get_by!(Organization, slug: "demo-org")
      IO.puts("✓ Demo organization already exists: #{o.name}")
      o
  end

# Create or get demo team
IO.puts("Creating demo team...")
_team =
  case Agents.create_team(%{
    name: "Demo Team",
    slug: "demo-team",
    organization_id: org.id,
    settings: %{
      "description" => "A demo team for testing"
    }
  }) do
    {:ok, t} ->
      IO.puts("✓ Demo team created: #{t.name}")
      t
    {:error, _} ->
      t = Repo.get_by!(Team, slug: "demo-team")
      IO.puts("✓ Demo team already exists: #{t.name}")
      t
  end

# Create demo API key only if none exist
IO.puts("Creating demo API key...")
existing_keys = Organizations.list_api_keys(org.id)
{plain_key, created} =
  if existing_keys == [] do
    {:ok, _api_key, key} = Organizations.create_api_key(org.id, "Demo API Key")
    IO.puts("✓ Demo API key created")
    {key, true}
  else
    IO.puts("✓ Demo API key already exists")
    {nil, false}
  end

IO.puts("\n" <> String.duplicate("=", 60))
IO.puts("DEMO CREDENTIALS")
IO.puts(String.duplicate("=", 60))
IO.puts("\nWeb Login:")
IO.puts("  Email: demo@suchteam.dev")
IO.puts("  Password: demo_password_123")
if created and plain_key do
  IO.puts("\nAPI Key:")
  IO.puts("  #{plain_key}")
  IO.puts("\n⚠️  SAVE THIS API KEY - IT WON'T BE SHOWN AGAIN!")
else
  IO.puts("\nAPI Key: (use existing key from organization settings)")
end
IO.puts(String.duplicate("=", 60) <> "\n")

