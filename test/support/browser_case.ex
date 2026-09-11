defmodule SandboxDemoWeb.BrowserCase do
  use ExUnit.CaseTemplate

  alias PhoenixTest.Playwright.Case

  using opts do
    quote do
      use SandboxDemo.CommandedSandbox, unquote(opts)
      use SandboxDemoWeb, :verified_routes
      import PhoenixTest
      @moduletag :feature
    end
  end

  setup_all context do
    Case.do_setup_all(context)
  end

  setup context do
    # Playwright checks out SQL and puts the test's sandbox metadata in the
    # browser's user-agent. Start Commanded after that checkout, before visit/2.
    session = Case.do_setup(context)
    SandboxDemo.CommandedSandbox.start!(context.commanded_application)
    session
  end
end
