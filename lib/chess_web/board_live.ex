defmodule ChessWeb.BoardLive do
  use ChessWeb, :live_component

  def update(assigns, socket) do
  {:ok,
  socket
  |> assign(:chess_game_topic_id, assigns.id)
  |> assign(:pieces, assigns.pieces)
  |> assign(:selected_square, nil)}
  end

  @impl Phoenix.LiveView
  def handle_event("move_piece_from", %{"x" => x, "y" => y}, socket) do
    {x, _} = Integer.parse(x)
    {y, _} = Integer.parse(y)
    square = x_y_into_chess_square(x, y)
    selected_square = socket.assigns.selected_square
    IO.inspect(square)
    if square == selected_square do
      selected_square == nil
    end
    {:noreply, assign(socket, :selected_square, square)}
  end

  @impl Phoenix.LiveView
  def handle_event("move_piece_to", %{"x" => x, "y" => y}, socket) do
    selected_square = socket.assigns.selected_square
    if selected_square do
      {x, _} = Integer.parse(x)
      {y, _} = Integer.parse(y)
      square = x_y_into_chess_square(x, y)
      {:noreply, handle_piece_moved(socket, "bk", square)}
    else
      {:noreply, socket}
    end
  end

  defp handle_piece_moved(
    %{assigns: %{pieces: pieces}} = socket,
    piece,
    square
  ) do
    ChessWeb.Endpoint.broadcast(socket.assigns.chess_game_topic_id, "piece_moved", %{"square" => square})
    socket
    |> put_flash(:info, "Rating submitted successfully")
    |> assign(
    :pieces,
    Map.delete(socket.assigns.pieces, socket.assigns.selected_square)
    )
  end

  defp get_square_color(x, y, selected_square) do
    # TODO: Fix this shit
    if selected_square == x_y_into_chess_square(x, y) do
      "selected"
    else
      if rem(y, 2) == 0 do
        if rem(x, 2) == 0 do
          "black"
        else
          "white"
        end
      else
        if rem(x, 2) == 0 do
          "white"
        else
          "black"
        end
      end
    end
  end

  defp is_piece(x, y, pieces) do
    letter = x_y_into_chess_square(x, y)
    piece = Map.get(pieces, letter)
    piece_into_class(piece)

  end

  defp x_y_into_chess_square(x, y) do
    letter = List.to_string([64 + y])
    "#{letter}#{x}"
  end

  defp piece_into_class(nil), do: nil
  defp piece_into_class({is_black, type}) do
    "#{black_into_class(is_black)} #{type_into_class(type)}"
  end

  defp black_into_class(true), do: "black"
  defp black_into_class(false), do: "white"

  defp type_into_class("k"), do: "king"
  defp type_into_class("q"), do: "queen"
  defp type_into_class("r"), do: "rook"
  defp type_into_class("b"), do: "bishop"
  defp type_into_class("kn"), do: "knight"
  defp type_into_class("p"), do: "pawn"
end
