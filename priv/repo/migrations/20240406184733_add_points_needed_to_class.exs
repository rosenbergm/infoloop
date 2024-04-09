defmodule Infoloop.Repo.Migrations.AddPointsNeededToClass do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:classes) do
      add :points_needed, :bigint
    end
  end

  def down do
    alter table(:classes) do
      remove :points_needed
    end
  end
end
