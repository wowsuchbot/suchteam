defmodule Suchteam.Billing.UsageRecord do
  use Ecto.Schema
  import Ecto.Changeset

  @valid_metric_types ~w(agent_hours task_count api_calls)

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "usage_records" do
    field :metric_type, :string
    field :quantity, :integer, default: 0
    field :recorded_at, :utc_datetime
    field :metadata, :map, default: %{}
    
    belongs_to :organization, Suchteam.Organizations.Organization

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(usage_record, attrs) do
    usage_record
    |> cast(attrs, [:organization_id, :metric_type, :quantity, :recorded_at, :metadata])
    |> validate_required([:organization_id, :metric_type, :quantity, :recorded_at])
    |> validate_inclusion(:metric_type, @valid_metric_types)
    |> validate_number(:quantity, greater_than_or_equal_to: 0)
  end

  def valid_metric_types, do: @valid_metric_types
end
