use Mix.Config

config :easypost,
  easypost_endpoint: System.get_env("EASYPOST_ENDPOINT"),
  easypost_key: System.get_env("EASYPOST_TEST_KEY")
