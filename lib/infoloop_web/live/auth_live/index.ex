defmodule InfoloopWeb.AuthLive.Index do
  use InfoloopWeb, :guest_live_view

  def mount(params, session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1 class="text-4xl font-bold py-4">Vítej v systému Infoloop</h1>

    <p class="pb-4">
      Systém je určený pro studenty Gymnázia nad Alejí, kteří si zapsali semináře programování. Přihlašujte se pomocí svých školních Google účtů (těch, které končí na <em>@student.alej.cz</em>), jiné vám fungovat nebudou.
    </p>

    <.link navigate={~p"/auth/user/google"}>
      <.button>Přihlásit se</.button>
    </.link>
    """
  end
end
