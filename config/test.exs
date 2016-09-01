use Mix.config

config :easypost_elixir,
  easypost_endpoint: System.get_env("EASYPOST_ENDPOINT")
  easypost_key: System.get_env("EASYPOST_TEST_KEY")
