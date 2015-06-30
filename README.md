# Elixir Easypost Client


```elixir
# config/config.exs

config :my_app, easypost_endpoint: "https://api.easypost.com/v2/",
                easypost_key: "##############"
```

### use

```elixir
defmodule MyApp.Somemodule do
  use Easypost.Client, endpoint: Application.get_env(:my_app, :easypost_endpoint),                    
 					   key: Application.get_env(:my_app, :easypost_key)

  def verify_user_address(user) do
  	//where user.address is map containing required fields
    case verify_address(user.address) do
      {:ok, response} ->
        response
      {:error, status, reason} ->
        reason
    end
  end
end

```

### Installation

Note: This library is untested and not ready to use

```elixir
def deps do
  [ {:easypost, git: "https://github.com/Dania02525/easypost.git"}]
end
```