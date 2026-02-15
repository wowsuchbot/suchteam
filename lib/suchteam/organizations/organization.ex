defmodule Suchteam.Organizations.Organization do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "organizations" do
    field :name, :string
    field :slug, :string
    field :settings, :map, default: %{}
    
    belongs_to :owner, Suchteam.Accounts.User
    has_many :members, Suchteam.Organizations.OrganizationMember
    has_many :teams, Suchteam.Agents.Team
    has_one :subscription, Suchteam.Billing.Subscription
    has_many :api_keys, Suchteam.Organizations.ApiKey
    has_many :usage_records, Suchteam.Billing.UsageRecord

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :slug, :owner_id, :settings])
    |> validate_required([:name, :slug, :owner_id])
    |> validate_length(:name, min: 2, max: 100)
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/, message: "must be lowercase alphanumeric and dashes")
    |> validate_length(:slug, min: 2, max: 50)
    |> unique_constraint(:slug)
  end

  @doc """
  Generates a slug from the organization name.
  """
  def generate_slug(name) do
    name
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\s-]/, "")
    |> String.replace(~r/\s+/, "-")
    |> String.slice(0..49)
  end
end
