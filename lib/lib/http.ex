#Http 模块
defmodule Xin.Http do
  @moduledoc """
    phoenix conn in http相关函数
  """

  @doc """
  判断是否移动端 参数 conn
  """
  def is_mobile?(conn) do
    h = headers(conn)[:"user-agent"] |> String.downcase
    String.contains?(h, "android") or String.contains?(h, "iphone")
  end

  @doc """
  获取格式化的headers
  """
  def headers(conn) do
    Enum.map(conn.req_headers, fn {k,v} -> {String.to_atom(k),v} end)
  end

  @doc """
  获取authorization
  """
  def authorization(conn) do
    a = headers(conn)[:"authorization"]
    a || nil
  end

  def full_path(conn) do
    headers_data = headers(conn)
    http = if headers_data[:"x-scheme"], do: headers_data[:"x-scheme"], else: "http"
    host = headers_data[:host]
    path = conn.request_path
    query_path = if conn.query_string != "" do
      "?" <> conn.query_string
    else
      ""
    end    
    "#{http}://#{host}#{path}#{query_path}"
  end
end

