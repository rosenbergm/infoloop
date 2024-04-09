defmodule Infoloop.Accounts.Token do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication.TokenResource]

  token do
    api Infoloop.Accounts
  end

  postgres do
    table "tokens"
    repo Infoloop.Repo
  end
end
