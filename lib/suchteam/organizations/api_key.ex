defmodule Suchteam.Organizations.ApiKey do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "api_keys" do
    field :name, :string
    field :key_hash, :string
    field :prefix, :string
    field :last_used_at, :utc_datetime
    field :expires_at, :utc_datetime
    field :revoked_at, :utc_datetime
    
    belongs_to :organization, Suchteam.Organizations.Organization

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(api_key, attrs) do
    api_key
    |> cast(attrs, [:organization_id, :name, :key_hash, :prefix, :expires_at])
    |> validate_required([:organization_id, :name, :key_hash, :prefix])
    |> validate_length(:name, min: 1, max: 100)
    |> unique_constraint(:key_hash)
  end

  @doc """
  Generates a new API key with format: sk_{env}_{random}
  Returns {plain_key, key_hash, prefix}
  """
  def generate_key(env \\ "live") do
    random = :crypto.strong_rand_bytes(32) |> Base.encode64(padding: false)
    plain_key = "sk_#{env}_#{random}"
    key_hash = :crypto.hash(:sha256, plain_key) |> Base.encode16(case: :lower)
    prefix = String.slice(plain_key, 0..11)
    
    {plain_key, key_hash, prefix}
  end

  @doc """
  Hashes an API key for comparison.
  """
  def hash_key(key) when is_binary(key) do
    :crypto.hash(:sha256, key) |> Base.encode16(case: :lower)
  end
end
