defmodule Suchteam.Repo.Migrations.CreateApiKeys do
  use Ecto.Migration

  def change do
    create table(:api_keys, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :organization_id, references(:organizations, type: :binary_id, on_delete: :delete_all), null: false
      add :name, :string, null: false
      add :key_hash, :string, null: false
      add :prefix, :string, null: false  # First 8 chars for display (e.g., "sk_live_")
      add :last_used_at, :utc_datetime
      add :expires_at, :utc_datetime
      add :revoked_at, :utc_datetime
      
      timestamps(type: :utc_datetime)
    end

    create index(:api_keys, [:organization_id])
    create unique_index(:api_keys, [:key_hash])
  end
end
