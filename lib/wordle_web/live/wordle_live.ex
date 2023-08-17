defmodule WordleWeb.WordleLive do
  use WordleWeb, :live_view

  @api_endpoint "https://interviewing.venteur.co/api/wordle"
  @five_letter_words ~w(HOMES JUMPY PIZZA FIRST AZYME QUIFF YOWZA JOCKS ABACK DADDY GABLE KABOB)
  @clue_options ~w(w g y)

  def render(assigns) do
    ~H"""
    <p>Guesses:</p>
    <ol type="1">
      <%= for guess <- @guesses do %>
        <li><%= guess %></li>
      <% end %>
    </ol>
    <br />
    <p>Current guess:</p>
    <b><%= @current_guess %></b>
    <p>Enter this word into your wordle game and then record the results here below.</p>
    <.form for={@form} phx-change="validate" phx-submit="submit">
      <.input type="hidden" field={@form["word"]} value={@current_guess} />
      <.input type="text" field={@form["clue"]} placeholder="XXYGX" />
      <button>Submit</button>
    </.form>
    """
  end

  def mount(_params, _, socket) do
    first_word = Enum.random(@five_letter_words)

    {:ok,
     socket
     |> assign(:guesses, [first_word])
     |> assign(:current_guess, first_word)
     |> assign(:form, to_form(%{}))}
  end

  def handle_event("validate", _, socket) do
    {:noreply, socket}
  end

  def handle_event("submit", %{"word" => word, "clue" => clue}, socket) do
    result = String.upcase(call_api(word, clue))
    guesses = socket.assigns.guesses ++ [result]

    {:noreply,
     socket
     |> assign(:guesses, guesses)
     |> assign(:current_guess, result)}
  end

  defp call_api(word, clue) do
    {:ok, result} =
      HTTPoison.post(
        @api_endpoint,
        Jason.encode!([%{"word" => word, "clue" => clue}]),
        [{"Content-Type", "application/json"}]
      )

    Jason.decode!(result.body)["guess"]
  end
end
