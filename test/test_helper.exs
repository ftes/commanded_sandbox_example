Mimic.copy(SandboxDemo, type_check: true)
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(SandboxDemo.Repo, :manual)

# Core-only runs do not need to launch the Node.js driver.
filters = ExUnit.configuration()
feature_excluded? = Enum.any?(filters[:exclude], &(&1 in [:feature, {:feature, true}]))
feature_included? = Enum.any?(filters[:include], &(&1 in [:feature, {:feature, true}]))

unless feature_excluded? && !feature_included? do
  {:ok, playwright} = PhoenixTest.Playwright.Supervisor.start_link()
  ExUnit.after_suite(fn _ -> Supervisor.stop(playwright) end)
end

{:ok, {_address, port}} = SandboxDemoWeb.Endpoint.server_info(:http)
Application.put_env(:phoenix_test, :base_url, "http://localhost:#{port}")
