defmodule InfoloopWeb.Router do
  use InfoloopWeb, :router

  use AshAuthentication.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {InfoloopWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
  end

  scope "/", InfoloopWeb do
    pipe_through :browser

    ash_authentication_live_session :not_authenticated,
      on_mount: [{InfoloopWeb.LiveUserAuth, :live_no_user}] do
      live "/", AuthLive.Index
    end

    auth_routes_for Infoloop.Accounts.User, to: AuthController

    sign_in_route(on_mount: [{InfoloopWeb.LiveUserAuth, :live_no_user}])

    sign_out_route AuthController
  end

  scope "/app", InfoloopWeb do
    pipe_through [:browser, :require_authenticated_user]

    sign_out_route AuthController

    ash_authentication_live_session :dashboard,
      on_mount: [{InfoloopWeb.LiveUserAuth, :live_user_required}] do
      live "/", HomeDashboardLive
      live "/:class_id", ClassLive
      live "/:class_id/edit", EditClassLive
    end
  end

  scope "/admin", InfoloopWeb do
    pipe_through :browser

    ash_authentication_live_session :admin,
      on_mount: [{InfoloopWeb.LiveUserAuth, :live_user_admin}] do
      live "/", AdminDashboardLive
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", InfoloopWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:infoloop, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: InfoloopWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must log in to access this page.")
      |> redirect(to: "/sign-in")
      |> halt()
    end
  end
end
