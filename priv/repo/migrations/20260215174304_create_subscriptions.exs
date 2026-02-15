defmodule Suchteam.Repo.Migrations.CreateSubscriptions do
  use Ecto.Migration

  def change do
    create table(:subscriptions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :organization_id, references(:organizations, type: :binary_id, on_delete: :delete_all), null: false
      add :plan, :string, null: false, default: "free"  # free, pro, enterprise
      add :status, :string, null: false, default: "active"  # active, canceled, past_due, trialing
      add :stripe_customer_id, :string
      add :stripe_subscription_id, :string
      add :current_period_start, :utc_datetime
      add :current_period_end, :utc_datetime
      add :cancel_at_period_end, :boolean, default: false
      
      timestamps(type: :utc_datetime)
    end

    create index(:subscriptions, [:organization_id])
    create unique_index(:subscriptions, [:stripe_subscription_id])
  end
end
