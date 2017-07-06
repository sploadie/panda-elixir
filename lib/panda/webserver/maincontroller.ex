defmodule Panda.WebServer.MainController do
  def init(req, state) do
    handle(req, state)
  end

  def handle(request, state) do
    # reply/4 takes three arguments:
    #   * The HTTP response status (200, 404, etc.)
    #   * A list of 2-tuples representing headers
    #   * The body of the response
    #   * The original request
    req = :cowboy_req.reply(
      200,
      [ {"content-type", "text/html"} ],
      EEx.eval_file(Path.relative_to_cwd("views/index.eex"), [matches: Panda.upcoming_matches()]),
      request
    )

    # handle/2 returns a tuple starting containing :ok, the reply, and the
    # current state of the handler.
    {:ok, req, state}
  end


  @doc """
  Do any cleanup necessary for the termination of this handler.
  Usually you don't do much with this.  If things are breaking,
  try uncommenting the output lines here to get some more info on what's happening.
  """
  def terminate(_reason, _request, _state) do
    #IO.puts("Terminating for reason: #{inspect(reason)}")
    #IO.puts("Terminating after request: #{inspect(request)}")
    #IO.puts("Terminating with state: #{inspect(state)}")
    :ok
  end
end