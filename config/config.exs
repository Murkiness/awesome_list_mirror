# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

config :awesome_list, github_access_token: System.get_env("FUNB_GITHUB_TOKEN")

config :awesome_interface, AwesomeInterfaceWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "BE95Z16TwaOgSoR98ONjHwryIHsJGga/pjgUUor2BtVQ62QmoMt0OW7q3H7NlcUG",
  render_errors: [view: AwesomeInterfaceWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: AwesomeInterface.PubSub,
  live_view: [signing_salt: "q6mHP19/"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"