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

    define :get_by_assignment_and_user,
      args: [:assignment_id, :user_id],
      action: :by_assignment_and_user
  end

  actions do
    defaults [:create, :read, :update, :destroy]

    read :by_id do
      argument :id, :uuid, allow_nil?: false
      get? true
      filter expr(id == ^arg(:id))
    end

    read :by_assignment_and_user do
      argument :assignment_id, :uuid, allow_nil?: false
      argument :user_id, :uuid, allow_nil?: false

      get? true

      filter expr(assignment_id == ^arg(:assignment_id) and user_id == ^arg(:user_id))
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
    belongs_to :user, Infoloop.Accounts.User do
      api Infoloop.Accounts
      attribute_writable? true
    end

    belongs_to :assignment, Infoloop.Points.Assignment do
      attribute_writable? true
    end
  end
end
