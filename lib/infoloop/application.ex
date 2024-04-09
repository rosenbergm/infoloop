defmodule Infoloop.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      InfoloopWeb.Telemetry,
      Infoloop.Repo,
      {DNSCluster, query: Application.get_env(:infoloop, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Infoloop.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Infoloop.Finch},
      # Start a worker by calling: Infoloop.Worker.start_link(arg)
      # {Infoloop.Worker, arg},
      # Start to serve requests, typically the last entry
      InfoloopWeb.Endpoint,
      {AshAuthentication.Supervisor, otp_app: :infoloop}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Infoloop.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    InfoloopWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
