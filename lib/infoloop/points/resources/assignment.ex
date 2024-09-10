defmodule Infoloop.Points.Assignment do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "assignments"
    repo Infoloop.Repo
  end

  code_interface do
    define_for Infoloop.Points
    define :create, action: :create
    define :read_all, action: :read
    define :update, action: :update
    define :destroy, action: :destroy
    define :get_by_id, args: [:id], action: :by_id
    define :get_by_class_id, args: [:class_id], action: :by_class_id
  end

  actions do
    defaults [:create, :read, :update, :destroy]

    read :by_id do
      argument :id, :uuid, allow_nil?: false
      get? true
      filter expr(id == ^arg(:id))
    end

    read :by_class_id do
      argument :class_id, :uuid, allow_nil?: false

      filter expr(class_id == ^arg(:class_id))
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :string do
      allow_nil? false
    end

    attribute :description, :string

    attribute :max_points, :integer do
      allow_nil? false
    end

    attribute :bonus, :boolean do
      allow_nil? false
      default false
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :completions, Infoloop.Points.Completion

    belongs_to :class, Infoloop.Points.Class do
      attribute_writable? true
    end
  end
end
