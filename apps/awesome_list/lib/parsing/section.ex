defmodule AwesomeList.Parsing.Section do
    alias AwesomeList.Parsing.{Section, SectionItem}

    defstruct title: nil, description: nil, items: nil

    @type t :: %Section{title: String.t(), description: String.t(), items: [SectionItem.t()]}

end