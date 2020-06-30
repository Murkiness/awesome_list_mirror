defmodule AwesomeList.Parsing.SectionItem do
    alias AwesomeList.Parsing.SectionItem
    
    defstruct link: nil, description: nil, stars: nil, days_from_last_commit: nil, repo_name: nil, owner: nil

    @type t :: %SectionItem{
        link: String.t(),
        description: String.t(), 
        stars: integer, 
        days_from_last_commit: integer, 
        repo_name: String.t(), 
        owner: String.t()
    }
end