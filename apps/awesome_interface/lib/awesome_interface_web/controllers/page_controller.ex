defmodule AwesomeInterfaceWeb.PageController do
  use AwesomeInterfaceWeb, :controller

  alias AwesomeList.Storage

  def index(conn, _params) do
    {error, min_stars} = get_star_value(conn.query_params)

    data = Storage.get_awesome_data(min_stars)
    |> Enum.sort_by(&Map.fetch(&1, :title))

    conn
    |> handle_error(error)
    |> render("index.html", data: data)
  end

  defp get_star_value(%{"min_stars" => value}) do
    case Integer.parse(value) do
      {_, ""} -> {nil, String.to_integer(value)}
      {_, _} -> {:error, 0}
      :error -> {:error, 0}
    end
  end

  defp get_star_value(_), do: 0

  defp handle_error(conn, :error), do: put_flash(conn, :error, "min_stars accepts only integer values")

  defp handle_error(conn, _), do: conn
end
