Application.put_env(:easypost, :easypost_endpoint, System.get_env("EASYPOST_ENDPOINT"))
Application.put_env(:easypost, :easypost_test_key, System.get_env("EASYPOST_TEST_KEY"))

ExUnit.start()