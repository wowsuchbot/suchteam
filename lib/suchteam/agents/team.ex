defmodule Suchteam.Agents.Team do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "teams" do
    field(:name, :string)
    field(:slug, :string)
    field(:settings, :map, default: %{})

    belongs_to(:organization, Suchteam.Organizations.Organization)

    timestamps(type: :utc_datetime)
  end

  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :slug, :settings, :organization_id])
    |> validate_required([:name, :slug])
    |> unique_constraint(:slug)
  end
end
