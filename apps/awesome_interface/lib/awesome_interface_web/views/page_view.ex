defmodule AwesomeInterfaceWeb.PageView do
  use AwesomeInterfaceWeb, :view

  def make_short_link(link) do
    title = link
    |> String.split("/")
    |> List.last()

    raw("<a href=\"#{link}\">#{title}</a>")
  end

  def link_for_section(section_name) do
    section_link = make_link_for_section(section_name)
    raw("<a href=\"##{section_link}\">#{section_name}</a>")
  end

  defp make_link_for_section(section_name) do
    section_link = section_name
      |> String.split(" ")
      |> Enum.map(&String.downcase(&1))
      |> Enum.join("-")
  end

  def section_title(section_name) do
    section_link = make_link_for_section(section_name)
    raw("<h2 id=\"#{section_link}\">#{section_name}</h2>")
  end
end
