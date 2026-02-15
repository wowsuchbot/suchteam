defmodule Suchteam.Repo.Migrations.AddOrganizationIdToTeams do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :organization_id, references(:organizations, type: :binary_id, on_delete: :delete_all)
    end

    create index(:teams, [:organization_id])
  end
end
