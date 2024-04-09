defmodule Infoloop.Accounts.Secrets do
  use AshAuthentication.Secret

  def secret_for([:authentication, :tokens, :signing_secret], Infoloop.Accounts.User, _) do
    {:ok, "agEFOG16D0DY76MmEzcj3o4zljrzZ0maQEfCbKmKntffJYZUBg9bC80MSfWi3TUP"}

    # case IO.inspect(Application.fetch_env(:infoloop, Infoloop.Endpoint)) do
    #   {:ok, endpoint_config} ->
    #     IO.inspect(endpoint_config)
    #     Keyword.fetch(endpoint_config, :secret_key_base)

    #   :error ->
    #     :error
    # end
  end
end
