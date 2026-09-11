defmodule SandboxDemoWeb.PageController do
  use SandboxDemoWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
