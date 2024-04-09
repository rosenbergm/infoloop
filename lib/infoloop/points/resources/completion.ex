defmodule Infoloop.Points.Completion do
  use Ash.Resource, data_layer: AshPostgres.DataLayer

  postgres do
    table "completions"
    repo Infoloop.Repo
  end

  code_interface do
    define_for Infoloop.Points
    define :create, action: :create
    define :read_all, action: :read
    define :update, action: :update
    define :destroy, action: :destroy
    define :get_by_id, args: [:id], action: :by_id
  end

  actions do
    defaults [:create, :read, :update, :destroy]

    read :by_id do
      argument :id, :uuid, allow_nil?: false
      get? true
      filter expr(id == ^arg(:id))
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :status, :atom, constraints: [one_of: [:submitted, :missing]], default: :missing
    attribute :points, :integer

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :user, Infoloop.Accounts.User, api: Infoloop.Accounts
    belongs_to :assignment, Infoloop.Points.Assignment
  end
end
