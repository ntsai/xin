# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :xin,
  ecto_repos: [Xin.Repo]

# Configures the endpoint
config :xin, Xin.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "NnjT5yHdVDAAPVa45o+aTAKysScYlcnVLz2h0Qo+Bv1o61Ptc/1z3nEuHOXFj5cF",
  render_errors: [view: Xin.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Xin.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :xin, :sms,
  api_key: "973ff3b797b1cadc7ca2xxxxxxxd8",
  api_url: "https://sms.yunpian.com/v2/sms/single_send.json"


config :xin, :qiniu,
  access_key: "access_key",
  secret_key: "secret_key",
  scope_name: "空间名",
  scope_url:  "空间url地址"


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
