import Config

config :nostrum,
  token: "",
  gateway_intents: :all

if File.exists?("config/secret.exs"), do: import_config("secret.exs")
