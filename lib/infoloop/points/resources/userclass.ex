defmodule Infoloop.Points.UserClass do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "user_classes"
    repo Infoloop.Repo
  end

  relationships do
    belongs_to :user, Infoloop.Accounts.User,
      api: Infoloop.Accounts,
      primary_key?: true,
      allow_nil?: false

    belongs_to :class, Infoloop.Points.Class, primary_key?: true, allow_nil?: false
  end

  actions do
    defaults [:create, :read, :update, :destroy]
  end
end
