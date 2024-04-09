defmodule InfoloopWeb.AdminDashboardLive do
  use InfoloopWeb, :live_view

  alias Infoloop.Points.{Assignment, Class}

  def render(assigns) do
    ~H"""
    <h2>Owned classes</h2>
    <div>
      <%= for c <- @o_classes do %>
        <div>
          <div><%= c.title %>
            <.link patch={~p"/#{c.id}"}>go</.link></div>

          <button phx-click="delete_asgn" phx-value-asgn-id={c.id}>delete</button>
        </div>
      <% end %>
    </div>
    <h2>Joined classes</h2>
    <div>
      <%= for c <- @j_classes do %>
        <div>
          <div><%= c.title %></div>
          <button phx-click="delete_asgn" phx-value-asgn-id={c.id}>delete</button>
        </div>
      <% end %>
    </div>
    <h2>Create Asgn</h2>
    <.form :let={f} for={@create_form} phx-submit="create_asgn">
      <.input type="text" field={f[:title]} placeholder="input title" />
      <.button type="submit">create</.button>
    </.form>
    <h2>Update Post</h2>
    <.form :let={f} for={@update_form} phx-submit="update_asgn">
      <.label>Asgn Name</.label>
      <.input type="select" field={f[:post_id]} options={@post_selector} />
      <.input type="text" field={f[:title]} placeholder="input content" />
      <.button type="submit">Update</.button>
    </.form>
    """
  end

  def mount(_params, session, socket) do
    asgns = Assignment.read_all!()

    IO.inspect(socket.assigns)

    owned_classes = Class.read_all_by_teacher!(socket.assigns.current_user.id)

    joined_classes =
      Class.read_all_by_participant!(socket.assigns.current_user.id)
      |> IO.inspect(label: "joined clases")

    socket =
      assign(socket,
        assignments: asgns,
        o_classes: owned_classes,
        j_classes: joined_classes,
        post_selector: selector(asgns),
        create_form: AshPhoenix.Form.for_create(Assignment, :create) |> to_form(),
        update_form:
          AshPhoenix.Form.for_update(List.first(asgns, %Assignment{}), :update) |> to_form()
      )

    {:ok, socket}
  end

  def handle_event("create_asgn", %{"form" => %{"title" => title}}, socket) do
    Assignment.create(%{title: title, max_points: 15})

    asgns = Assignment.read_all!()

    {:noreply, assign(socket, asgns: asgns, post_selector: selector(asgns))}
  end

  defp selector(asgns) do
    for post <- asgns do
      {post.title, post.id}
    end
  end
end
