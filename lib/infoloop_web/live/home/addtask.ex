defmodule InfoloopWeb.AddTaskLive do
  use InfoloopWeb, :live_view

  alias Infoloop.Points.{Assignment, Class}

  def render(assigns) do
    ~H"""
    <.back navigate={~p"/app/#{@class.id}"}>Zpět</.back>

    <section class="flex items-center justify-between py-4">
      <h1 class="text-4xl font-bold">Add task</h1>
    </section>

    <.simple_form for={@create_form} phx-submit="create_assignment">
      <.input label="Title" type="text" field={@create_form[:title]} placeholder="Esej o medvědech" />

      <.input
        label="Description"
        type="textarea-mono"
        class="font-mono"
        field={@create_form[:description]}
        placeholder="Napište esej na dvě normostrany..."
      />

      <.input label="Maximum points" type="number" field={@create_form[:max_points]} placeholder="15" />

      <.input type="hidden" field={@create_form[:class_id]} value={@class.id} />

      <.input label="Bonus?" type="checkbox" field={@create_form[:bonus]} />

      <:actions>
        <.button type="submit">Add</.button>
      </:actions>
    </.simple_form>
    """
  end

  def mount(%{"class_id" => id}, _session, socket) do
    class = Class.get_by_id!(id)

    {:ok,
     assign(socket,
       class: class,
       create_form:
         AshPhoenix.Form.for_create(Assignment, :create)
         |> to_form()
     )}
  end

  def handle_event("create_assignment", %{"form" => form_params}, socket) do
    class = socket.assigns.class

    IO.inspect(class)
    IO.inspect(form_params)

    Assignment.create!(form_params)

    {:noreply, socket |> redirect(to: ~p"/app/#{class.id}")}
  end
end
