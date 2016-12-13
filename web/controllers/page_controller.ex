# defmodule Xin.PageController do
#   # use Xin.Web, :controller
#   use Xin.Lib.Rest, Xin.Web

#   @method "lucrd"

#   router "product"
  

# end

defmodule Auth do
  use Phoenix.Controller

  def init(options) do
    IO.puts "game"
    options
  end

  def call(conn, _params) do    
    json halt(conn), %{}
  end

end

defmodule Xin.PageController do
  use Xin.Web, :controller

  plug Auth


  def auth(conn, _params) do
    json conn,%{}
  end

  def show(conn, _params) do
    text conn, "sdfsf"

  end

end
