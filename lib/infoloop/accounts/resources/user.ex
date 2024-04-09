defmodule Infoloop.Accounts.User do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication]

  attributes do
    uuid_primary_key :id
    attribute :email, :ci_string, allow_nil?: false

    attribute :first_name, :string, allow_nil?: false
    attribute :last_name, :string, allow_nil?: false

    attribute :gid, :string, allow_nil?: false

    attribute :is_admin, :boolean, default: false, allow_nil?: false

    attribute :picture, :string
  end

  calculations do
    calculate :full_name, :string, expr(first_name <> " " <> last_name)
  end

  relationships do
    has_many :owned_classes, Infoloop.Points.Class,
      api: Infoloop.Points,
      destination_attribute: :teacher_id

    many_to_many :classes, Infoloop.Points.Class do
      through Infoloop.Points.UserClass
      api Infoloop.Points
      source_attribute_on_join_resource :user_id
      destination_attribute_on_join_resource :class_id
    end

    has_many :completions, Infoloop.Points.Completion, api: Infoloop.Points
  end

  authentication do
    api Infoloop.Accounts

    strategies do
      google do
        redirect_uri fn _, _ -> {:ok, Application.get_env(:infoloop, :redirect_uri)} end
        client_id fn _, _ -> {:ok, Application.get_env(:infoloop, :client_id)} end
        client_secret fn _, _ -> {:ok, Application.get_env(:infoloop, :client_secret)} end
      end
    end

    tokens do
      enabled? true
      token_resource Infoloop.Accounts.Token

      signing_secret Infoloop.Accounts.Secrets
    end
  end

  code_interface do
    define_for Infoloop.Accounts
    define :create, action: :create
    define :read_all, action: :read
    define :update, action: :update
    define :destroy, action: :destroy
  end

  actions do
    defaults [:create, :read, :update, :destroy]
  end

  actions do
    create :register_with_google do
      argument :user_info, :map, allow_nil?: false
      argument :oauth_tokens, :map, allow_nil?: false
      upsert? true
      upsert_identity :unique_email

      change AshAuthentication.GenerateTokenChange

      change fn changeset, _ctx ->
        user_info = Ash.Changeset.get_argument(changeset, :user_info)

        changeset
        |> Ash.Changeset.change_attribute(:email, user_info["email"])
        |> Ash.Changeset.change_attribute(:first_name, user_info["given_name"])
        |> Ash.Changeset.change_attribute(:last_name, user_info["family_name"])
        |> Ash.Changeset.change_attribute(:picture, user_info["picture"])
        |> Ash.Changeset.change_attribute(:gid, user_info["sub"])
      end
    end
  end

  postgres do
    table "users"
    repo Infoloop.Repo
  end

  identities do
    identity :unique_email, [:email]
  end
end
