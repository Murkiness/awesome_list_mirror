defmodule StorageTest do
    use ExUnit.Case

    alias AwesomeList.Storage
    alias AwesomeList.Parsing.{Section, SectionItem}

    setup_all do
        File.cwd!()
        |> Path.join(Atom.to_charlist(Application.get_env(:awesome_list, :storage)))
        |> File.rm()

        Storage.put_data("sect1", setup_section_with_configured_items([3, 5, 10]))
        Storage.put_data("sect2", setup_section_with_configured_items([6, 8, 12]))

        :ok
    end

    def setup_section_with_configured_items(star_value_list) do
        star_value_list
        |> Enum.map(fn star -> setup_section_item_with_stars(star) end)
        |> create_section_with_given_items()
    end

    def create_section_with_given_items(items) do
        %Section{title: "Section", description: "test description", items: items}
    end

    def setup_section_item_with_stars(stars_value) do
        %SectionItem{
            link: "https://github.com/benoitc/erlang-metrics", 
            description: "A generic interface to different metrics systems in Erlang.", 
            owner: "benoitc",
            repo_name: "erlang-metrics",
            stars: stars_value, 
            days_from_last_commit: nil }
    end

    def concat_stars_from_sections(sections) do
        sections
        |> Enum.reduce([], fn s, acc -> Enum.concat(acc, Enum.map(s.items, fn item -> item.stars end)) end)
        |> Enum.sort()
    end
    
    test "get_awesome_data returns empty list when there in no repos with enough stars" do
        assert Enum.count(Storage.get_awesome_data(100)) == 0
    end

    test "get_awesome_data returns correctly filtered sections and items" do
        sections = Storage.get_awesome_data(8)
        assert Enum.count(sections) == 2
        assert concat_stars_from_sections(sections) == [8, 10, 12]
    end

    test "get_awesome_data returns all data if stars argument is not provided" do
        sections = Storage.get_awesome_data()
        assert concat_stars_from_sections(sections) == [3, 5, 6, 8, 10, 12]
    end
end