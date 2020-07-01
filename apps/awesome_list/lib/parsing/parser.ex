defmodule AwesomeList.Parsing.Parser do
    use Private
    require Logger

    alias AwesomeList.Parsing.{Section, SectionItem}

    @spec parse_section_structures(String.t()) :: [Section.t()]
    def parse_section_structures(raw_response) do
        Logger.info("Parsing readme")

        raw_response
        |> parse_section_names
        |> parse_structures(raw_response)
        |> Enum.filter(fn x -> Enum.count(x.items) > 0 end)
    end

    private do
        @spec parse_structures([String.t()], String.t()) :: [Section.t()]
        defp parse_structures(section_names, raw_response) do
            raw_response
            |> String.split("\n##", trim: true)
            |> Enum.drop(1)
            |> Enum.filter(fn x -> Enum.any?(section_names, fn y -> String.starts_with?(x, " #{y}") end) end)
            |> Enum.map(&parse_structure/1)
        end

        @spec parse_structure(String.t()) :: Section.t()
        defp parse_structure(raw_section) do
            section_strings = raw_section
            |> prepare_section()
    
            title = parse_title(section_strings)
            description = parse_description(section_strings)
            items = parse_section_items(section_strings)
    
            %Section{title: title, description: description, items: items}    
        end

        @spec transform_str_to_section_item(String.t()) :: SectionItem.t()
        defp transform_str_to_section_item(str) do
            strs = str
            |> String.split(" - ")
            |> Enum.map(fn x -> String.trim(x) end)

            link = strs
            |> List.first()
            |> String.split(["(", ")"])
            |> Enum.at(1)

            description = List.last(strs)
            {owner, repo_name} = parse_parts_from_link(link)

            case owner do
                :error -> ""
                _ -> %SectionItem{description: description, link: link, owner: owner, repo_name: repo_name}
            end
        end

        @spec parse_parts_from_link(String.t()) :: { String.t(), String.t()} | { atom, String.t()}
        defp parse_parts_from_link(link) do
            link
            |> String.split("/")
            |> match_parts
        end

        defp match_parts(["https:", "", "github.com", owner, repo]) when repo != "" do
            {owner, repo}
        end

        defp match_parts(_), do: {:error, "url parts were not parsed properly"}

        @spec parse_section_names(String.t()) :: [String.t()]
        defp parse_section_names(raw_response) do
            raw_response
            |> split_text_to_section_names()
            |> clean_section_names()
        end
    end

    @spec split_text_to_section_names(String.t()) :: [String.t()]
    defp split_text_to_section_names(raw_response) do
        raw_response
        |> String.split("\n-", trim: true)
        |> Enum.slice(0..1)
        |> Enum.at(1)
        |> String.split("\n", trim: true)
        |> Enum.slice(1..-1)
    end

    @spec clean_section_names([String.t()]) :: [String.t()]
    defp clean_section_names(section_list) do
        section_list
        |> Enum.map(fn x ->
            x
            |> String.split(["[", "]"])
            |> Enum.at(1)
        end)
    end

    @spec parse_section_items([String.t()]) :: [SectionItem.t()]
    defp parse_section_items(section_strings) do
        section_strings
        |> Enum.filter(fn x -> String.contains?(x, "https://github.com") end)
        |> Enum.map(&transform_str_to_section_item/1)
        |> Enum.filter(fn x -> x != "" end)
    end

    @spec parse_title([String.t()]) :: String.t()
    defp parse_title(section_strings) do
        section_strings
        |> List.first()
    end

    @spec parse_description([String.t()]) :: String.t()
    defp parse_description(section_strings) do
        section_strings
        |> Enum.filter(fn x -> String.starts_with?(x, "*") and String.ends_with?(x, "*") end)
        |> List.first()
        |> String.replace("*", "")
    end

    @spec prepare_section(String.t()) :: [String.t()]
    defp prepare_section(raw_section) do
        raw_section
        |> String.split("\n")
        |> Enum.map(fn x -> String.trim(x) end)
    end
    
end