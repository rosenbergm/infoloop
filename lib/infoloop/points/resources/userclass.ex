defmodule Infoloop.Points.UserClass do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "user_classes"
    repo Infoloop.Repo
  end

  code_interface do
    define_for Infoloop.Points
    define :create, action: :create
  end

  relationships do
    belongs_to :user, Infoloop.Accounts.User do
      api Infoloop.Accounts
      primary_key? true
      allow_nil? false
      attribute_writable? true
    end

    belongs_to :class, Infoloop.Points.Class do
      primary_key? true
      allow_nil? false
      attribute_writable? true
    end
  end

  actions do
    defaults [:create, :read, :update, :destroy]
  end
end
