defmodule Panda.HTTP do
    @url "https://api.pandascore.co/"

    @doc """
    Returns parsed JSON for any Pandascore REST lookup
    """
    @spec get!(String.t, Map) :: any
    def get!(path, query \\ %{}) do
        response = HTTPotion.get!(
            @url <> path,
            query: Map.put(query, :token, Application.get_env(:panda, :api_key)),
            timeout: 30000
        )
        Poison.decode! response.body
    end
end