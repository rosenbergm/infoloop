defmodule InfoloopWeb.AuthController do
  alias Infoloop.Accounts
  alias Infoloop.Accounts.User
  use InfoloopWeb, :controller
  use AshAuthentication.Phoenix.Controller

  def success(conn, _activity, user, _token) do
    return_to = get_session(conn, :return_to) || ~p"/"

    case Accounts.count!(User) do
      1 ->
        User.update!(user, %{"is_admin" => true})
    end

    conn
    |> delete_session(:return_to)
    |> store_in_session(user)
    |> assign(:current_user, user)
    |> redirect(to: return_to)
  end

  def failure(conn, activity, reason) do
    IO.puts("failed to login")
    IO.inspect(activity)
    IO.inspect(reason)

    conn
    |> put_status(401)
    |> render("failure.html")
  end

  def sign_out(conn, _params) do
    return_to = get_session(conn, :return_to) || ~p"/"

    conn
    |> clear_session()
    |> redirect(to: return_to)
  end
end
