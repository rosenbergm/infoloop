defmodule InfoloopWeb.MarkAssignmentLive do
  alias Infoloop.Points.Class
  alias Infoloop.Points.Assignment
  alias Infoloop.Points.Completion

  use InfoloopWeb, :live_view

  def render(assigns) do
    ~H"""
    <.back navigate={~p"/app/#{@class.id}"}>Zpět</.back>

    <section class="flex items-center justify-between py-4">
      <h1 class="text-4xl font-bold">Hodnocení: <%= @assignment.title %></h1>
    </section>

    <.table id="class-users" rows={@class.users}>
      <:col :let={u} label="Student"><%= u.full_name %></:col>
      <:col :let={u} label="Hodnocení">
        <.live_component
          module={InfoloopWeb.Mark}
          id={"mark-#{u.id}-#{@assignment.id}"}
          user_id={u.id}
          assignment={@assignment}
        />
      </:col>
    </.table>
    """
  end

  def mount(%{"class_id" => class_id, "task_id" => task_id}, _session, socket) do
    task = Assignment.get_by_id!(task_id)

    class =
      Class.get_by_id!(class_id)

    IO.inspect(class.users)

    {:ok,
     assign(socket,
       assignment: task,
       class: class
       #  create_form:
       #    AshPhoenix.Form.for_create(Assignment, :create)
       #    |> to_form()
     )}
  end
end
