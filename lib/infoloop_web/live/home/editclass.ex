defmodule InfoloopWeb.EditClassLive do
  use InfoloopWeb, :live_view

  alias Infoloop.Points.Class

  def render(assigns) do
    ~H"""
    <.back navigate={~p"/app/#{@class.id}"}>Zpět</.back>

    <section class="flex items-center justify-between py-4">
      <h1 class="text-4xl font-bold">Edit class</h1>
    </section>

    <.simple_form for={@update_form} phx-submit="update_class">
      <.input label="Title" type="text" field={@update_form[:title]} placeholder="Přírodověda" />

      <.input
        label="Description"
        type="textarea-mono"
        class="font-mono"
        field={@update_form[:description]}
        placeholder="Za úlohy druhého typu získáte osm bodíku..."
      />

      <.input
        label="Points needed"
        type="number"
        field={@update_form[:points_needed]}
        placeholder="15"
      />

      <.input label="Archived?" type="checkbox" field={@update_form[:archived]} />

      <:actions>
        <.button type="submit">Update</.button>
      </:actions>
    </.simple_form>
    """
  end

  def mount(%{"class_id" => id}, _session, socket) do
    class = Class.get_by_id!(id)

    {:ok,
     assign(socket,
       class: class,
       update_form: AshPhoenix.Form.for_update(class, :update) |> to_form()
     )}
  end

  def handle_event("update_class", %{"form" => form_params}, socket) do
    class = socket.assigns.class

    Class.get_by_id!(class.id)
    |> Class.update!(form_params)

    {:noreply, socket |> redirect(to: ~p"/app/#{class.id}")}
  end
end
