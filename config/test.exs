import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :sandbox_demo, SandboxDemo.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: String.to_integer(System.get_env("DATABASE_PORT", "5432")),
  database: "sandbox_demo_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# A real HTTP server is needed for browser tests. Port 0 avoids collisions.
config :sandbox_demo, SandboxDemoWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 0],
  secret_key_base: "Jr4AsN/KB2rh67aVAt5w6SNbecKv59hTdMY4zaq/BK9bED94zzcW0KM3bUWPyCjL",
  server: true

# In test we don't send emails
config :sandbox_demo, SandboxDemo.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Sort query params output of verified routes for robust url comparisons
config :phoenix,
  sort_verified_routes_query_params: true

# Each test supervises its own named Commanded tree; the OTP app stays running.
config :sandbox_demo, start_commanded: false, sql_sandbox: SandboxDemoWeb.Sandbox

config :phoenix_test,
  otp_app: :sandbox_demo,
  endpoint: SandboxDemoWeb.Endpoint,
  playwright: [
    browser_pools: [[id: :default_pool, size: 2]],
    timeout: 5_000,
    trace: System.get_env("PW_TRACE", "false") == "true",
    trace_dir: "tmp/traces"
  ]
