defmodule Infoloop.Points.Class do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "classes"
    repo Infoloop.Repo
  end

  code_interface do
    define_for Infoloop.Points
    define :create, action: :create
    define :read_all, action: :read
    define :update, action: :update
    define :destroy, action: :destroy
    define :get_by_id, args: [:id], action: :by_id

    define :read_all_by_teacher, args: [:id], action: :by_teacher
    define :read_all_by_participant, args: [:id], action: :by_participant
  end

  actions do
    defaults [:create, :read, :update, :destroy]

    read :by_id do
      argument :id, :uuid, allow_nil?: false
      get? true

      prepare build(load: [users: [:full_name], teacher: [:full_name]])

      filter expr(id == ^arg(:id))
    end

    read :by_teacher do
      argument :id, :uuid, allow_nil?: false
      filter expr(teacher.id == ^arg(:id))
    end

    read :by_participant do
      argument :id, :uuid, allow_nil?: false

      filter expr(exists(users, id == ^arg(:id)))
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :string do
      allow_nil? false
    end

    attribute :description, :string

    attribute :archived, :boolean, allow_nil?: false, default: false
    attribute :points_needed, :integer

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :teacher, Infoloop.Accounts.User, api: Infoloop.Accounts

    has_many :users_join_assoc, Infoloop.Points.UserClass, api: Infoloop.Points

    many_to_many :users, Infoloop.Accounts.User do
      api Infoloop.Accounts
      through Infoloop.Points.UserClass
      source_attribute_on_join_resource :class_id
      destination_attribute_on_join_resource :user_id
    end

    has_many :assignments, Infoloop.Points.Assignment
  end
end
