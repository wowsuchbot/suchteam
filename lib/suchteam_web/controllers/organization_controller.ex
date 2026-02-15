defmodule SuchteamWeb.OrganizationController do
  use SuchteamWeb, :controller

  alias Suchteam.Organizations
  alias Suchteam.Billing

  def index(conn, _params) do
    user = conn.assigns.current_user
    organizations = Organizations.list_user_organizations(user.id)
    
    render(conn, :index, organizations: organizations)
  end

  def new(conn, _params) do
    render(conn, :new)
  end

  def create(conn, %{"organization" => org_params}) do
    user = conn.assigns.current_user

    case Organizations.create_organization(user, org_params) do
      {:ok, organization} ->
        conn
        |> put_flash(:info, "Organization created successfully!")
        |> redirect(to: "/organizations/#{organization.id}")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Error creating organization")
        |> render(:new)
    end
  end

  def show(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    organization = Organizations.get_organization!(id)

    # Check if user is a member
    if Organizations.member?(organization, user.id) do
      subscription = Billing.get_subscription(organization.id)
      api_keys = Organizations.list_api_keys(organization.id)
      
      # Get usage stats
      today = Date.utc_today()
      start_of_month = Date.beginning_of_month(today)
      usage = Billing.get_usage_summary(organization.id, 
        DateTime.new!(start_of_month, ~T[00:00:00]),
        DateTime.utc_now()
      )

      render(conn, :show, 
        organization: organization,
        subscription: subscription,
        api_keys: api_keys,
        usage: usage
      )
    else
      conn
      |> put_flash(:error, "You don't have access to this organization")
      |> redirect(to: "/organizations")
    end
  end

  def settings(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    organization = Organizations.get_organization!(id)

    # Check if user is admin or owner
    if Organizations.member?(organization, user.id, "admin") do
      render(conn, :settings, organization: organization)
    else
      conn
      |> put_flash(:error, "You don't have permission to access organization settings")
      |> redirect(to: "/organizations/#{id}")
    end
  end

  def update(conn, %{"id" => id, "organization" => org_params}) do
    user = conn.assigns.current_user
    organization = Organizations.get_organization!(id)

    # Check if user is admin or owner
    if Organizations.member?(organization, user.id, "admin") do
      case Organizations.update_organization(organization, org_params) do
        {:ok, organization} ->
          conn
          |> put_flash(:info, "Organization updated successfully!")
          |> redirect(to: "/organizations/#{organization.id}")

        {:error, _changeset} ->
          conn
          |> put_flash(:error, "Error updating organization")
          |> render(:settings, organization: organization)
      end
    else
      conn
      |> put_flash(:error, "You don't have permission to update this organization")
      |> redirect(to: "/organizations/#{id}")
    end
  end
end
