defmodule Suchteam.Repo.Migrations.CreateOrganizations do
  use Ecto.Migration

  def change do
    create table(:organizations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :slug, :string, null: false
      add :owner_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :settings, :map, default: %{}
      
      timestamps(type: :utc_datetime)
    end

    create unique_index(:organizations, [:slug])
    create index(:organizations, [:owner_id])
  end
end
