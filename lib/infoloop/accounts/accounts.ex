defmodule Infoloop.Accounts do
  use Ash.Api

  resources do
    resource Infoloop.Accounts.User
    resource Infoloop.Accounts.Token
  end
end
