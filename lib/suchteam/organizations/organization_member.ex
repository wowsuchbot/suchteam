defmodule Suchteam.Organizations.OrganizationMember do
  use Ecto.Schema
  import Ecto.Changeset

  @valid_roles ~w(owner admin member)

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "organization_members" do
    field :role, :string, default: "member"
    
    belongs_to :organization, Suchteam.Organizations.Organization
    belongs_to :user, Suchteam.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(attrs, [:organization_id, :user_id, :role])
    |> validate_required([:organization_id, :user_id, :role])
    |> validate_inclusion(:role, @valid_roles)
    |> unique_constraint([:organization_id, :user_id])
  end

  def valid_roles, do: @valid_roles
end
