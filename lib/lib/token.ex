defmodule Xin.Lib.Token do
  import Joken

  @doc """
  token插件
  """

  @secret "my_secret"


  # 创建一个token
  def new(conn, data) do
    data
    |> token
    |> with_signer(hs256(@secret))
    |> sign
    |> get_compact
  end
  
  # 解析一个token
  def get(key \\ %{}) do
    t = key
    |> token
    |> with_signer(hs256(@secret))
    |> verify   
    t.claims
  end

end


defmodule Xin.Token.Auth do
  import Plug.Conn

  def init(default) do
    default
  end

  def call(conn, default) do
    authorization = Xin.Http.authorization(conn)
    if authorization do
      conn = Map.put conn, :user, Xin.Token.get(authorization)
    else
      data = conn |> fetch_session |> get_session(:user)
      if data, do: conn = Map.put conn, :user, data
    end
    
    conn
  end
  
end
