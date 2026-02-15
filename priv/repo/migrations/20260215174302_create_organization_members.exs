defmodule Suchteam.Repo.Migrations.CreateOrganizationMembers do
  use Ecto.Migration

  def change do
    create table(:organization_members, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :organization_id, references(:organizations, type: :binary_id, on_delete: :delete_all), null: false
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :role, :string, null: false, default: "member"  # owner, admin, member
      
      timestamps(type: :utc_datetime)
    end

    create index(:organization_members, [:organization_id])
    create index(:organization_members, [:user_id])
    create unique_index(:organization_members, [:organization_id, :user_id])
  end
end
