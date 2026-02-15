defmodule Suchteam.Repo.Migrations.CreateUsageRecords do
  use Ecto.Migration

  def change do
    create table(:usage_records, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :organization_id, references(:organizations, type: :binary_id, on_delete: :delete_all), null: false
      add :metric_type, :string, null: false  # agent_hours, task_count, api_calls
      add :quantity, :integer, null: false, default: 0
      add :recorded_at, :utc_datetime, null: false
      add :metadata, :map, default: %{}
      
      timestamps(type: :utc_datetime)
    end

    create index(:usage_records, [:organization_id, :recorded_at])
    create index(:usage_records, [:metric_type])
  end
end
