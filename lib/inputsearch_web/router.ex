defmodule InputsearchWeb.Router do
  use InputsearchWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", InputsearchWeb do
    pipe_through :browser
    live "/", Live.DemoLive
    # get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", InputsearchWeb do
  #   pipe_through :api
  # end
end
