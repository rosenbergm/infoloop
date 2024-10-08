defmodule InfoloopWeb.ClassLive do
  require Ash.Query
  use InfoloopWeb, :live_view

  alias Infoloop.Points.{Class, Assignment, Completion}

  def markdown(assigns) do
    text = if assigns.text == nil, do: "", else: assigns.text

    markdown_html =
      String.trim(text)
      |> Earmark.as_html!(code_class_prefix: "lang- language-")
      |> Phoenix.HTML.raw()

    assigns = assign(assigns, :markdown, markdown_html)

    ~H"""
    <div class="px-4 py-2 pt-4 prose">
      <%= @markdown %>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <.back navigate={~p"/app"}>Zpět</.back>

    <section class="flex items-center justify-between">
      <h1 class="text-4xl font-bold py-4"><%= @class.title %></h1>

      <div class="flex gap-4">
        <p><%= @class.teacher.full_name %></p>

        <.link :if={@user.id == @class.teacher_id} patch={~p"/app/#{@class.id}/edit"}>
          <.icon name="hero-pencil-square" /> Edit
        </.link>
      </div>
    </section>

    <details class="group  mb-4 border-2 border-black">
      <summary class="group-hover:bg-neutral-200 px-4 py-2 cursor-context-menu">
        <span class="pl-2">Detaily o předmětu</span>
      </summary>

      <.markdown text={@class.description} />
    </details>

    <article
      :if={@user.id != @class.teacher_id and @maximum_points != 0}
      class="grid grid-cols-2 gap-4 mb-4"
    >
      <section class="flex-1 border-2 border-black px-4 py-2">
        <p>Máte <%= @reached_points %> z <%= @maximum_points %> bodů.</p>
      </section>
      <section class="flex-1 border-2 border-black px-4 py-2">
        <p>
          Na splnění předmětu potřebujete: <br />
          <%= @needed_points %> bodů.
        </p>
      </section>
      <section class="flex items-center justify-between border-2 border-black pl-4">
        <p class="py-2">
          Splněno?
        </p>

        <div class={(if @reached_points >= @needed_points do "bg-green-600" else "bg-red-600" end) <>  " aspect-square h-10"}>
        </div>
      </section>
    </article>

    <article :if={@user.id == @class.teacher_id} class="space-x-4">
      <.link patch={~p"/app/#{@class.id}/task/add"}>
        <.icon name="hero-plus" /> Přidat úkol
      </.link>

      <.link patch={~p"/app/#{@class.id}/students"}>
        <.icon name="hero-user-plus" /> Přidat studenta
      </.link>
    </article>

    <.table id="assignments" rows={@asgns}>
      <:col :let={a} label="Úkol">
        <%= a.title %>

        <span :if={a.bonus} title="Bonusový úkol">
          <.icon name="hero-star" />
        </span>
      </:col>
      <:col :let={a} label="Body">
        <p :if={!a.completion || a.completion.status == :missing}>
          Neodevzdáno (max. <%= a.max_points %> bodů)
        </p>
        <p :if={a.completion} class="font-mono">
          <span class="inline-block w-[3ch]"><%= a.completion.points %></span> / <%= a.max_points %>
        </p>
      </:col>

      <:action :let={a}>
        <.link
          :if={@user.id == @class.teacher_id}
          patch={~p"/app/#{@class.id}/task/#{a.id}/grade"}
          class="font-normal"
        >
          <.icon name="hero-chart-bar-square" /> Mark
        </.link>
      </:action>
    </.table>
    """
  end

  def handle_event("open-grading", %{"assignment" => assignment}, socket) do
    IO.inspect(assignment)

    show_modal("confirm")

    {:noreply, socket |> assign(:selected_task, assignment)}
  end

  def mount(%{"class_id" => id}, _session, %{assigns: %{current_user: user}} = socket) do
    Class.get_by_id(id)
    |> case do
      {:error, _} ->
        {:ok, socket |> put_flash(:error, "Invalid class accessed.") |> redirect(to: ~p"/")}

      {:ok, class} ->
        IO.inspect(user.id)

        asgns =
          Assignment
          |> Ash.Query.filter(class_id == ^class.id)
          |> Ash.Query.sort([:inserted_at])
          |> Ash.Query.load(
            completions:
              Infoloop.Points.Completion
              |> Ash.Query.filter(user_id == ^user.id)
          )
          |> Infoloop.Points.read!()
          |> Enum.map(fn a ->
            completion = List.first(a.completions)

            Map.put(a, :completion, completion)
          end)

        {count, max_sum} =
          asgns
          |> Enum.filter(&(not &1.bonus))
          |> Enum.map(& &1.max_points)
          |> then(&{Enum.count(&1), Enum.sum(&1)})

        reached_sum =
          asgns
          |> Enum.map(& &1.completion)
          |> Enum.filter(&(not is_nil(&1)))
          |> Enum.map(& &1.points)
          |> Enum.sum()

        {:ok,
         assign(socket,
           user: user,
           class: class,
           asgns: asgns,
           asgns_count: count,
           reached_points: reached_sum,
           maximum_points: max_sum,
           needed_points: class.points_needed,
           selected_task: nil
         )}
    end
  end
end
