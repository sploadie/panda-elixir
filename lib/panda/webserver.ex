defmodule Panda.WebServer do
  def start do
    :cowboy.start_http(
      :http,
      100,
      [{:port, 7878}],
      [{ :env, [{:dispatch, routes()}]}]
    )
  end

  def routes do
    :cowboy_router.compile([
      { :_,
        [
          # {"/", :cowboy_static, {:priv_file, :panda, "index.html"}},
          {"/public/[...]", :cowboy_static, {:priv_dir, :panda, "public"}},

          # Serve a dynamic page with a custom handler
          # When a request is sent to a dynamic page, pass the request to the custom handler
          # defined in module DynamicPageHandler.
          {"/", Panda.WebServer.MainController, []},

          # Serve websocket requests.
          # {"/websocket", WebsocketHandler, []}
      ]}
    ])
  end
end
