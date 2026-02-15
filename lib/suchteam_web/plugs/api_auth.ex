defmodule SuchteamWeb.ApiAuth do
  @moduledoc """
  Authentication plug for API requests using API keys.
  """

  import Plug.Conn
  import Phoenix.Controller
  alias Suchteam.Organizations
  alias Suchteam.Billing

  @doc """
  Authenticates API requests using Bearer token (API key).
  """
  def authenticate_api_request(conn, _opts) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> api_key] ->
        case Organizations.validate_api_key(api_key) do
          {:ok, organization} ->
            conn
            |> assign(:current_organization, organization)
            |> assign(:api_authenticated, true)

          {:error, :invalid_key} ->
            conn
            |> put_status(:unauthorized)
            |> json(%{error: "Invalid API key"})
            |> halt()
        end

      _ ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Missing API key. Provide 'Authorization: Bearer YOUR_API_KEY' header"})
        |> halt()
    end
  end

  @doc """
  Checks if the organization can perform the action based on their subscription.
  """
  def check_subscription_limits(conn, action) do
    organization = conn.assigns[:current_organization]

    if organization && Billing.can_perform_action?(organization.id, action) do
      conn
    else
      limits = Billing.Subscription.plan_limits(organization.subscription.plan)
      
      conn
      |> put_status(:forbidden)
      |> json(%{
        error: "Subscription limit exceeded",
        plan: organization.subscription.plan,
        limits: limits
      })
      |> halt()
    end
  end

  @doc """
  Records API usage for rate limiting and billing.
  """
  def record_api_usage(conn, _opts) do
    if organization = conn.assigns[:current_organization] do
      Billing.record_usage(organization.id, "api_calls", 1, %{
        path: conn.request_path,
        method: conn.method
      })
    end

    conn
  end
end
