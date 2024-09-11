defmodule InfoloopWeb.AddClassLive do
  use InfoloopWeb, :live_view

  alias Infoloop.Points.{Class}

  def render(assigns) do
    ~H"""
    <.back navigate={~p"/app"}>Zpět</.back>

    <section class="flex items-center justify-between py-4">
      <h1 class="text-4xl font-bold">Add class</h1>
    </section>

    <.simple_form for={@create_form} phx-submit="create_class">
      <.input label="Title" type="text" field={@create_form[:title]} placeholder="Přírodověda" />

      <.input
        label="Description"
        type="textarea-mono"
        class="font-mono"
        field={@create_form[:description]}
        placeholder="Budeme se učit o zvířatech, které..."
      />

      <.input
        label="Points needed"
        type="number"
        field={@create_form[:points_needed]}
        placeholder="100"
      />

      <:actions>
        <.button type="submit">Add</.button>
      </:actions>
    </.simple_form>
    """
  end

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       create_form:
         AshPhoenix.Form.for_create(Class, :create)
         |> to_form()
     )}
  end

  def handle_event("create_class", %{"form" => form_params}, socket) do
    class = Class.create!(Map.put(form_params, "teacher_id", socket.assigns.current_user.id))

    {:noreply, socket |> redirect(to: ~p"/app/#{class.id}")}
  end
end
