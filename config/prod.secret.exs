use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or you later on).
config :xin, Xin.Endpoint,
  secret_key_base: "4x6aDhTFZzW4ddTJQU+yZmW59i2LX1YzaZ6XsCwsS+hQWD7CkvOZdjVCoI1syX0O"

# Configure your database
config :xin, Xin.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "xin_prod",
  pool_size: 20
