defmodule SuchteamWeb.Router do
  use SuchteamWeb, :router

  import SuchteamWeb.UserAuth

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {SuchteamWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_current_user)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :api_authenticated do
    plug(SuchteamWeb.ApiAuth, :authenticate_api_request)
    plug(SuchteamWeb.ApiAuth, :record_api_usage)
  end

  ## Public routes
  scope "/", SuchteamWeb do
    pipe_through([:browser, :redirect_if_user_is_authenticated])

    get("/login", SessionController, :new)
    post("/login", SessionController, :create)
    get("/register", RegistrationController, :new)
    post("/register", RegistrationController, :create)
  end

  ## Authenticated browser routes
  scope "/", SuchteamWeb do
    pipe_through([:browser, :require_authenticated_user])

    live("/", DashboardLive, :index)
    live("/chat", ChatLive, :index)
    
    delete("/logout", SessionController, :delete)
    get("/settings", SettingsController, :index)
    
    # Organization management
    get("/organizations", OrganizationController, :index)
    get("/organizations/new", OrganizationController, :new)
    post("/organizations", OrganizationController, :create)
    get("/organizations/:id", OrganizationController, :show)
    get("/organizations/:id/settings", OrganizationController, :settings)
    put("/organizations/:id", OrganizationController, :update)
  end

  scope "/agents", SuchteamWeb do
    pipe_through([:browser, :require_authenticated_user])

    live("/", AgentLive.Index, :index)
    live("/new", AgentLive.Index, :new)
    live("/:id", AgentLive.Show, :show)
  end

  ## Public API routes
  scope "/api", SuchteamWeb.Api do
    pipe_through(:api)

    get("/health", HealthController, :index)
  end

  ## Authenticated API routes
  scope "/api", SuchteamWeb.Api do
    pipe_through([:api, :api_authenticated])

    resources("/agents", AgentController, only: [:index, :show, :create, :delete])
    post("/agents/:id/tasks", AgentController, :delegate_task)
    get("/agents/:id/tasks", AgentController, :tasks)
  end

  if Application.compile_env(:suchteam, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: SuchteamWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end
end
