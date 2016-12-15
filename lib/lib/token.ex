defmodule Xin.Token do
  import Joken
  @moduledoc """
  jwt token模块

  配置 config.exs
  config :xin, :token,
    secret: "xxxxxxxxxxxxxxxx" 
  """
  @secret Application.get_env(:xin, :token)[:secret] || "secret_key"

  # 创建一个token
  def new(_conn, data) do
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

  @moduledoc """
  jwt token plug 模块
  """

  def init(default) do
    default
  end

  def call(conn, _default) do
    authorization = Xin.Http.authorization(conn)
    if authorization do
      Map.put conn, :user, Xin.Token.get(authorization)
    else
      data = conn |> fetch_session |> get_session(:user)
      if data, do: Map.put(conn, :user, data), else: conn
    end
  end

end
