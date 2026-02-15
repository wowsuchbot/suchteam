defmodule SuchteamWeb.SettingsController do
  use SuchteamWeb, :controller

  def index(conn, _params) do
    user = conn.assigns.current_user
    organizations = Suchteam.Organizations.list_user_organizations(user.id)
    
    render(conn, :index, organizations: organizations)
  end
end
