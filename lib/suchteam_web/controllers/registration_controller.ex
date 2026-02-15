defmodule SuchteamWeb.RegistrationController do
  use SuchteamWeb, :controller

  alias Suchteam.Accounts
  alias Suchteam.Organizations
  alias SuchteamWeb.UserAuth

  def new(conn, _params) do
    changeset = Accounts.change_user_registration(%Accounts.User{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        # Create a default organization for the new user
        org_name = user_params["organization_name"] || "#{user.email}'s Organization"
        {:ok, _organization} = Organizations.create_organization(user, %{name: org_name})

        conn
        |> put_flash(:info, "Account created successfully!")
        |> UserAuth.log_in_user(user)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end
end
