defmodule InfoloopWeb.Mark do
  import InfoloopWeb.CoreComponents
  alias Infoloop.Points.Completion
  use Phoenix.LiveComponent

  def render(assigns) do
    IO.inspect(assigns)

    ~H"""
    <span id={@id}>
      <.input
        name={"mark-grade-#{@user_id}-#{@assignment.id}"}
        value={@value}
        type="number"
        max={@assignment.max_points}
        placeholder="4"
        phx-blur="grade-input-blur"
        phx-value-user={@user_id}
        phx-value-assignment={@assignment.id}
        phx-target={@myself}
      />/<%= @assignment.max_points %>
    </span>
    """
  end

  def update(assigns, socket) do
    # IO.inspect(assigns)
    assignment_id = assigns.assignment.id
    user_id = assigns.user_id

    completion = Completion.get_by_assignment_and_user(assignment_id, user_id)

    value =
      case completion do
        {:error, _} ->
          0

        {:ok, c} ->
          c.points
      end

    {:ok,
     assign(socket,
       id: assigns.id,
       user_id: assigns.user_id,
       assignment: assigns.assignment,
       value: value
     )}
  end

  def handle_event(
        "grade-input-blur",
        %{"user" => user_id, "assignment" => assignment_id, "value" => value},
        socket
      ) do
    value = String.to_integer(value)

    Completion.create!(
      %{
        "points" => value,
        "user_id" => user_id,
        "assignment_id" => assignment_id,
        "status" => :submitted
      },
      upsert?: true
    )

    {:noreply, assign(socket, value: value)}
  end

  def mount(socket) do
    {:ok, socket}
  end
end
