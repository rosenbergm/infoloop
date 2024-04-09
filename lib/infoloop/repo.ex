defmodule Infoloop.Repo do
  use AshPostgres.Repo,
    otp_app: :infoloop

  def installed_extensions() do
    ["uuid-ossp", "citext"]
  end
end
