defmodule AwesomeList.Storage do
    alias AwesomeList.Parsing.Section

    @storage Application.get_env(:awesome_list, :storage)

    @spec get_awesome_data(integer) :: [Section.t()]
    def get_awesome_data(stars \\ 0) do
        get_all_data()
        |> get_sections()
        |> filter_by_stars(stars)
    end

    def put_data(key, value) do
        {:ok, table} = :dets.open_file(@storage, type: :set)
        :dets.insert(table,{key, value})
    end

    def get_all_data() do
        {:ok, table} = :dets.open_file(@storage, type: :set)
        :dets.match(table, {:"$1", :"$2"})
    end

    def close() do
        :dets.close(@storage)
    end

    defp filter_by_stars(section_list, min_stars) do
        section_list
        |> filter_sections_by_stars(min_stars)
        |> get_sections_with_filtered_items(min_stars)
    end

    defp filter_sections_by_stars(section_list, min_stars) do
        section_list
        |> Enum.filter(fn section -> Enum.any?(section.items,
            fn item -> item.stars >= min_stars end) 
        end)
    end

    defp get_sections_with_filtered_items(section_list, min_stars) do
        section_list
        |> Enum.map(
            fn section -> 
                Map.replace!(section, :items, Enum.filter(section.items, fn item -> item.stars >= min_stars end))
            end)
    end

    defp get_sections(dets_data) do
        dets_data
        |> Enum.map(fn lst -> Enum.at(lst, 1) end)
    end

end