defmodule SandboxDemoWeb.Sandbox do
  @moduledoc """
  Extends Phoenix's normal sandbox forwarding with the test's Mimic allowance.
  The metadata owner is the test process, which owns the application/0 stub.
  """

  def allow(repo, test_pid, child_pid) do
    Ecto.Adapters.SQL.Sandbox.allow(repo, test_pid, child_pid)
    Mimic.allow(SandboxDemo, test_pid, child_pid)
  end
end
