defmodule Suchteam.Billing.Subscription do
  use Ecto.Schema
  import Ecto.Changeset

  @valid_plans ~w(free pro enterprise)
  @valid_statuses ~w(active canceled past_due trialing)

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "subscriptions" do
    field :plan, :string, default: "free"
    field :status, :string, default: "active"
    field :stripe_customer_id, :string
    field :stripe_subscription_id, :string
    field :current_period_start, :utc_datetime
    field :current_period_end, :utc_datetime
    field :cancel_at_period_end, :boolean, default: false
    
    belongs_to :organization, Suchteam.Organizations.Organization

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [
      :organization_id,
      :plan,
      :status,
      :stripe_customer_id,
      :stripe_subscription_id,
      :current_period_start,
      :current_period_end,
      :cancel_at_period_end
    ])
    |> validate_required([:organization_id, :plan, :status])
    |> validate_inclusion(:plan, @valid_plans)
    |> validate_inclusion(:status, @valid_statuses)
    |> unique_constraint(:stripe_subscription_id)
  end

  @doc """
  Returns the plan limits for each subscription tier.
  """
  def plan_limits(plan) do
    case plan do
      "free" ->
        %{
          max_agents: 5,
          max_tasks_per_day: 100,
          max_api_calls_per_hour: 100,
          features: ["basic_agents", "web_interface"]
        }
      "pro" ->
        %{
          max_agents: 50,
          max_tasks_per_day: 10_000,
          max_api_calls_per_hour: 1_000,
          features: ["basic_agents", "web_interface", "api_access", "priority_support"]
        }
      "enterprise" ->
        %{
          max_agents: :unlimited,
          max_tasks_per_day: :unlimited,
          max_api_calls_per_hour: :unlimited,
          features: ["basic_agents", "web_interface", "api_access", "priority_support", "sla", "custom_integrations"]
        }
      _ ->
        plan_limits("free")
    end
  end

  def valid_plans, do: @valid_plans
  def valid_statuses, do: @valid_statuses
end
