defmodule SandboxDemo.Repo do
  use Ecto.Repo,
    otp_app: :sandbox_demo,
    adapter: Ecto.Adapters.Postgres
end
