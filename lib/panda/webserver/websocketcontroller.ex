defmodule Panda.WebServer.WebsocketController do
  @behaviour :cowboy_websocket

  # We are using the regular http init callback to perform handshake.
  #     http://ninenines.eu/docs/en/cowboy/2.0/manual/cowboy_handler/
  #
  # Note that handshake will fail if this isn't a websocket upgrade request.
  # Also, if your server implementation supports subprotocols,
  # init is the place to parse `sec-websocket-protocol` header
  # then add the same header to `req` with value containing
  # supported protocol(s).
  def init(req, state) do
    {:cowboy_websocket, req, state}
  end

  # Put any essential clean-up here.
  def terminate(_reason, _req, _state) do
    :ok
  end

  # websocket_handle deals with messages coming in over the websocket,
  # including text, binary, ping or pong messages. But you need not
  # handle ping/pong, cowboy takes care of that.
  def websocket_handle({:text, content}, req, state) do
    IO.puts "websocket_handle #{content}"

    # Use Poison to decode the JSON message and extract the word entered
    # by the user into the variable 'message'.
    {:ok, data} = Poison.decode(content)

    match_id = String.to_integer(data["match_id"])

    IO.puts "match_id #{match_id}"

    pid = self()
    Task.Supervisor.start_child(OddsSupervisor, fn -> send(pid, Panda.odds_for_match(match_id)) end)
    reply = receive do
      odds ->
        IO.puts "odds #{inspect odds}"

        odds = unless (odds === %{}), do: odds, else: "OPPONENTS UNKNOWN"

        {:ok, reply} = Poison.encode(%{"info" => inspect(odds)})

        # All websocket callbacks share the same return values.
        # See http://ninenines.eu/docs/en/cowboy/2.0/manual/cowboy_websocket/
        {:reply, {:text, reply}, req, state}
    end

    IO.puts "reply #{inspect reply}"
    reply
  end

  # Fallback clause for websocket_handle.  If the previous one does not match
  # this one just ignores the frame and returns `{:ok, state}` without
  # taking any action. A proper app should  probably intelligently handle
  # unexpected messages.
  def websocket_handle(frame, req, state) do
    IO.puts "websocket_handle\n#{inspect frame}\n#{inspect req}"
    {:ok, state}
  end

  # websocket_info is the required callback that gets called when erlang/elixir
  # messages are sent to the handler process. In this example, the only erlang
  # messages we are passing are the :timeout messages from the timing loop.
  #
  # In a larger app various clauses of websocket_info might handle all kinds
  # of messages and pass information out the websocket to the client.
  def websocket_info(_info, _req, state) do
    {:ok, state}
  end
end

