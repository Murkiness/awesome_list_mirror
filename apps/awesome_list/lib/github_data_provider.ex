defmodule AwesomeList.GithubDataProvider do
    require Logger
 
    @awesome_list_url "https://raw.githubusercontent.com/h4cc/awesome-elixir/master/README.md"
    @repo_endpoint "https://api.github.com/repos/"
    @github_token Application.get_env(:awesome_list, :github_access_token)

    def get_awesome_readme() do
        Logger.info("getting readme file's content")

        @awesome_list_url
        |> HTTPoison.get([], follow_redirect: true)
        |> handle_response()
        |> case do
            {:ok, body} -> body
            error -> error
        end
    end

    @callback get_repo_data(String.t(), String.t()) :: String.t()
    def get_repo_data(owner, repo_name) do
        link = @repo_endpoint <> owner <> "/" <> repo_name
        link
        |> HTTPoison.get(get_authorization_header(), follow_redirect: true)
        |> handle_response
        |> parse_response
    end

    defp handle_response({:ok, %{body: body, status_code: 200}}) do
        {:ok, body}
    end

    defp handle_response(_), do: {:error, :unexpected_response}

    defp parse_response({:ok, body}), do: Jason.decode(body)
    defp parse_response(error), do: error

    defp get_authorization_header() do
        ["Authorization": "token #{@github_token}"]
    end
end