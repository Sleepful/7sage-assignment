defmodule M.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      MWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: M.PubSub},
      # Start Finch
      {Finch, name: M.Finch},
      # Start the Endpoint (http/https)
      MWeb.Endpoint,
      
      # Start a worker by calling: M.Worker.start_link(arg)
      M.Data
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: M.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
