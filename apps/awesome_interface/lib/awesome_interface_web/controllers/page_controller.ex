defmodule AwesomeInterfaceWeb.PageController do
  use AwesomeInterfaceWeb, :controller

  alias AwesomeList.Storage

  def index(%{query_params: %{"min_stars" => min_stars}} = conn, _params) do
    {error, stars} = parse_star_value(min_stars)
    data = get_sorted_data(stars)

    conn
    |> handle_error(error)
    |> render("index.html", data: data)
  end

  def index(conn, _params) do
    render(conn, "index.html", data: get_sorted_data())
  end

  defp parse_star_value(stars) do
    case Integer.parse(stars) do
      {_, ""} -> {nil, String.to_integer(stars)}
      {_, _} -> {:error, 0}
      :error -> {:error, 0}
    end
  end

  defp get_sorted_data(stars \\ 0) do
    data = Storage.get_awesome_data(stars)
    |> Enum.sort_by(&Map.fetch(&1, :title))
  end

  defp handle_error(conn, :error), do: put_flash(conn, :error, "min_stars accepts only integer values")

  defp handle_error(conn, _), do: conn
end
