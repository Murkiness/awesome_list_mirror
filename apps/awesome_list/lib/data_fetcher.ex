defmodule AwesomeList.DataFetcher do
    use Private
    require Logger

    alias AwesomeList.Parsing.{Parser, Section, SectionItem}
    alias AwesomeList.Storage

    @github_data_provider Application.get_env(:awesome_list, :github_data_provider)
    @timeout 100000

    def gather_data() do
        Logger.info("Starting to gather data")

        @github_data_provider.get_awesome_readme()
        |> Parser.parse_section_structures()
        |> fetch_details_data_for_all_sections()
        |> put_data_to_storage()

        Logger.info("Data is updated")
        Storage.close()
    end

    @spec fetch_details_data_for_all_sections([Section.t()]) :: [Section.t()]
    def fetch_details_data_for_all_sections(section_list) do
        section_list
        |> Enum.map(&Task.async(fn -> fetch_details_for_section(&1) end))
        |> Enum.map(fn task -> Task.await(task, @timeout) end)
    end

    private do
        @spec fetch_details_for_section(Section.t()) :: Section.t()
        defp fetch_details_for_section(section) do
            Logger.info("Fetching details for #{section.description}")

            upd_items = section.items
            |> Enum.map(&Task.async(fn -> fetch_repo_details(&1) end))
            |> Enum.map(fn task -> Task.await(task, @timeout) end)
    
            %Section{section | items: upd_items}
        end

        @spec fetch_repo_details(SectionItem.t()) :: SectionItem.t()
        defp fetch_repo_details(%SectionItem{ owner: owner, repo_name: repo_name } = item) do
            {:ok, data} = @github_data_provider.get_repo_data(owner, repo_name)
            {stars, updated_at} = parse_repo_details(data)
            %SectionItem{item | stars: stars, days_from_last_commit: updated_at}
        end
    end

    defp parse_repo_details(%{"stargazers_count" => stargazers_count, "pushed_at" => updated_at}) do
        {stargazers_count, transform_date_to_days_from_last_update(updated_at)}
    end

    @spec transform_date_to_days_from_last_update(String.t()) :: integer
    defp transform_date_to_days_from_last_update(str_date) do
        {:ok, date, _} = DateTime.from_iso8601(str_date)
        seconds_diff = DateTime.diff(DateTime.utc_now(), date, :second)
        div(seconds_diff, 60 * 60 * 24)
    end

    @spec put_data_to_storage([Section.t()]) :: nil
    defp put_data_to_storage(sections) do
        Enum.each(sections, fn s -> Storage.put_data(s.title, s) end)
        nil
    end


end