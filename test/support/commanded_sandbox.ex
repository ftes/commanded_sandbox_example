defmodule SandboxDemo.CommandedSandbox do
  @moduledoc """
  Starts a fresh Commanded tree per test, within the main OTP application.
  ExUnit stops this tree before on_exit callbacks release the SQL transaction.
  Names are bounded by test modules and declared ExUnit parameter sets.
  """
  use Supervisor

  alias SandboxDemo.Articles.Projector

  defstruct [:application_name, :test_pid, :ready_ref]

  defmacro __using__(opts) do
    quote do
      @commanded_parameter_sets Keyword.get(unquote(opts), :parameterize)
      setup_all context do
        name =
          SandboxDemo.CommandedSandbox.application_name(
            __MODULE__,
            @commanded_parameter_sets,
            context
          )

        [commanded_application: name]
      end
    end
  end

  def application_name(module, nil, _context), do: module

  def application_name(module, parameter_sets, context) do
    index = Enum.find_index(parameter_sets, &(Map.take(context, Map.keys(&1)) == &1))
    Module.concat(module, "Case#{index}")
  end

  def start!(application_name) do
    sandbox = %__MODULE__{
      application_name: application_name,
      test_pid: self(),
      ready_ref: make_ref()
    }

    Mimic.stub(SandboxDemo, :application, fn -> application_name end)
    supervisor = ExUnit.Callbacks.start_supervised!({__MODULE__, sandbox})
    ready_ref = sandbox.ready_ref

    receive do
      {^ready_ref, _projector_pid} -> :ok
    after
      5_000 -> raise "Article projector did not start"
    end

    supervisor
  end

  def start_link(sandbox), do: Supervisor.start_link(__MODULE__, sandbox)

  @impl Supervisor
  def init(%__MODULE__{} = sandbox) do
    on_start = fn ->
      SandboxDemoWeb.Sandbox.allow(SandboxDemo.Repo, sandbox.test_pid, self())
      send(sandbox.test_pid, {sandbox.ready_ref, self()})
      :ok
    end

    # Checkpoints live in SQL. Distinct names prevent concurrent transactions
    # from contending for the same projection_versions row.
    children = [
      {SandboxDemo, name: sandbox.application_name},
      {Projector,
       application: sandbox.application_name,
       name: "#{sandbox.application_name}:articles",
       state: %{on_start: on_start}}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
