defmodule SandboxDemo.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SandboxDemoWeb.Telemetry,
      SandboxDemo.Repo,
      {DNSCluster, query: Application.get_env(:sandbox_demo, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SandboxDemo.PubSub},
      # Start a worker by calling: SandboxDemo.Worker.start_link(arg)
      # {SandboxDemo.Worker, arg},
      # Start to serve requests, typically the last entry
      SandboxDemoWeb.Endpoint
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SandboxDemo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SandboxDemoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
