defmodule DataFetcherTest do
    import Mox

    use ExUnit.Case

    alias AwesomeList.DataFetcher
    alias AwesomeList.Parsing.{Section, SectionItem}

    setup :verify_on_exit!

    setup_all do
      section_item1 = %SectionItem{
        link: "https://github.com/benoitc/erlang-metrics", 
        description: "A generic interface to different metrics systems in Erlang.", 
        owner: "benoitc",
        repo_name: "erlang-metrics",
        stars: nil, 
        days_from_last_commit: nil }

      section_item2 = %SectionItem{
          link: "https://github.com/badosu/coil", 
          description: "A generic interface to different metrics systems in Erlang.", 
          owner: "badosu",
          repo_name: "coil",
          stars: nil, 
          days_from_last_commit: nil }

      [section_item1: section_item1, section_item2: section_item2]
    end

    test "fetch_repo_details updates section item", context do
      GithubDataProviderMock
        |> expect(:get_repo_data, fn "benoitc", "erlang-metrics" -> {:ok, %{ "stargazers_count" => 55, "pushed_at" => "2020-03-10T09:06:01Z"} } end)

      updated_section_item = DataFetcher.fetch_repo_details(context[:section_item1])
      assert updated_section_item.stars == 55
      assert updated_section_item.days_from_last_commit != nil  
    end

    test "fetch_details_for_section updates section", context do
      section = %Section{title: "test", description: "no description", items: [context[:section_item1] , context[:section_item2]]}

      GithubDataProviderMock
      |> expect(:get_repo_data, fn "benoitc", "erlang-metrics" -> {:ok, %{ "stargazers_count" => 55, "pushed_at" => "2020-03-10T09:06:01Z"} } end)
      |> expect(:get_repo_data, fn "badosu", "coil" -> {:ok, %{"stargazers_count" => 66, "pushed_at" => "2019-07-10T09:06:01Z"} } end)

      updated_section = DataFetcher.fetch_details_for_section(section)
      for item <- updated_section.items do
        assert item.stars != nil
        assert item.days_from_last_commit != nil
      end
    end

    test "fetch_details_data_for_all_sections updates section items", context do
      section1 = %Section{title: "Section_1", description: "test description 1", items: [context[:section_item1]]}
      section2 = %Section{title: "Section_2", description: "test description 2", items: [context[:section_item2]]}

      sections = [section1, section2]

      GithubDataProviderMock
      |> expect(:get_repo_data, fn "benoitc", "erlang-metrics" -> {:ok, %{ "stargazers_count" => 55, "pushed_at" => "2020-03-10T09:06:01Z"} } end)
      |> expect(:get_repo_data, fn "badosu", "coil" -> {:ok, %{"stargazers_count" => 66, "pushed_at" => "2019-07-10T09:06:01Z"} } end)

      updated_sections = DataFetcher.fetch_details_data_for_all_sections(sections)

      for section <- updated_sections do
        for item <- section.items do
          assert item.stars != nil
          assert item.days_from_last_commit != nil
        end
      end
    end

end