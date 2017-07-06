defmodule Panda.HTTP do
    # use HTTPotion
    # use Poison

    @url "https://api.pandascore.co/"

    def get!(:lol, :games, query \\ []) do
        response = HTTPotion.get!(
            @url <> "matches",
            query: Keyword.put(query, :token, Application.get_env(:panda, :api_key)),
            timeout: 30000
        )
        Poison.decode! response.body
    end
end