defmodule InfoloopWeb.StudentsLive do
  alias Infoloop.Points.UserClass
  alias Infoloop.Accounts.User
  use InfoloopWeb, :live_view

  alias Infoloop.Points.{Assignment, Class}

  def render(assigns) do
    ~H"""
    <.back navigate={~p"/app/#{@class.id}"}>Zpět</.back>

    <section class="flex items-center justify-between py-4">
      <h1 class="text-4xl font-bold">Students management for <%= @class.title %></h1>
    </section>

    <.table id="class-users" rows={@class.users}>
      <:col :let={u} label="Jméno"><%= u.full_name %></:col>
    </.table>

    <section class="mt-4">
      <h2 class="text-3xl font-bold">Add new student</h2>
      <.simple_form for={@create_form} phx-submit="add_student">
        <.input label="Email" type="email" field={@create_form[:email]} placeholder="martin@alej.cz" />

        <:actions>
          <.button type="submit">Add</.button>
        </:actions>
      </.simple_form>
    </section>
    """
  end

  def mount(%{"class_id" => id}, _session, socket) do
    class = Class.get_by_id!(id)

    {:ok,
     assign(socket,
       class: class,
       create_form:
         AshPhoenix.Form.for_create(User, :create)
         |> to_form()
     )}
  end

  def handle_event("add_student", %{"form" => %{"email" => email}}, socket) do
    class = socket.assigns.class
    user = User.get_by_email!(email)

    IO.inspect(class)
    IO.inspect(user)

    UserClass.create!(%{"user_id" => user.id, "class_id" => class.id})

    {:noreply, socket |> redirect(to: ~p"/app/#{class.id}/students")}
  end
end
