defmodule Parsing.ParserTest do
    use ExUnit.Case

    alias AwesomeList.Parsing.{Parser, SectionItem}

    test "transform_str_to_section_item transforms string to section item" do
      str = "* [erlang-metrics](https://github.com/benoitc/erlang-metrics) - A generic interface to different metrics systems in Erlang."
      expected = %SectionItem{
        link: "https://github.com/benoitc/erlang-metrics", 
        description: "A generic interface to different metrics systems in Erlang.", 
        owner: "benoitc",
        repo_name: "erlang-metrics",
        stars: nil, 
        days_from_last_commit: nil }

      assert Parser.transform_str_to_section_item(str) == expected
    end

    test "transform_str_to_section_item returns empty string when link can not be parsed 1" do
      str = "* [erlang-metrics](https://github.com/benoitc/) - A generic interface to different metrics systems in Erlang."
      expected = ""

      assert Parser.transform_str_to_section_item(str) == expected
    end

    test "transform_str_to_section_item returns empty string when link can not be parsed 2" do
      str = "* [erlang-metrics](http://github.com/benoitc/erlang-metrics) - A generic interface to different metrics systems in Erlang."
      expected = ""

      assert Parser.transform_str_to_section_item(str) == expected
    end

    test "parse_section_names returns correct list of names" do
      {:ok, body} = read_file("github_readme.txt")
      parsed_names = Parser.parse_section_names(body)

      assert Enum.count(parsed_names) == 81
      assert List.first(parsed_names) == "Actors"
      assert Enum.at(parsed_names, 10) == "BSON"
      assert List.last(parsed_names) == "YAML"
    end

    test "parse_structure returns correct section structure" do
      {:ok, str} = read_file("section_data.txt")
      section = Parser.parse_structure(str)

      assert section.title == "Actors"
      assert section.description == "Libraries and tools for working with actors and such."
      assert Enum.count(section.items) == 2
    end

    test "parse_section_structures transforms response into array of section structures" do
      {:ok, body} = read_file("github_readme.txt")
      sections = Parser.parse_section_structures(body)

      assert Enum.count(sections) == 79
      Enum.each(sections, fn x -> 
        assert x.title != nil
        assert x.description != nil
        assert Enum.count(x.items) > 0
      end)

    end

    test "parse_parts" do
      link = "https://github.com/benoitc/erlang-metrics"

      assert Parser.parse_parts_from_link(link) == {"benoitc", "erlang-metrics"}

    end



    defp read_file(filename) do
      File.read(Path.join(__DIR__, filename))
    end
  end
  