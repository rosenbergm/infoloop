defmodule InfoloopWeb.HomeDashboardLive do
  use InfoloopWeb, :live_view

  alias Infoloop.Points.{Assignment, Class}

  def render(assigns) do
    ~H"""
    <h2 class="mb-2 font-medium">Owned classes</h2>
    <article class="grid grid-cols-2 gap-2">
      <%= for c <- @o_classes do %>
        <.link patch={~p"/app/#{c.id}"}>
          <section class="group border-2 border-black pt-2 flex items-end">
            <div class="text-2xl font-bold border-t-2 border-black flex-1 px-4 py-2 group-hover:bg-neutral-200">
              <%= c.title %>
            </div>
          </section>
        </.link>
      <% end %>
    </article>

    <h2 class="mb-2 mt-4 font-medium">Joined classes</h2>
    <article class="grid grid-cols-2 gap-2">
      <%= for c <- @j_classes do %>
        <.link patch={~p"/app/#{c.id}"}>
          <section class="group border-2 border-black pt-2 flex items-end">
            <div class="text-2xl font-bold border-t-2 border-black flex-1 px-4 py-2 group-hover:bg-neutral-200">
              <%= c.title %>
            </div>
          </section>
        </.link>
      <% end %>
    </article>
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
