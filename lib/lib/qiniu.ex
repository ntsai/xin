defmodule Xin.QiNiu do

  @moduledoc """
  添加七牛插件deps:

  {:qiniu, github: "tony612/qiniu"},

  添加启动
  applications: [:qiniu, :httpoison]

  参数例子：
  data = %Plug.Upload{content_type: "image/png", filename: "hikaru.png", path: "/var/folders/ns/lcjcq8nx213625_5yb8fylh80000gn/T//plug-1472/multipart-636914-225015-3"}

  配置 config.exs
  config :xin, :qiniu,
    access_key: "access_key",
    secret_key: "secret_key",
    scope_name: "空间名",
    scope_url:  "空间url地址"
  """

  @doc """
  传图片或者文件,返回 服务器图片地址, conn传入
  """
  def upload(conn) when is_map(conn) do
    config = Application.get_env :xin, :qiniu
    scope_name = config[:scope_name]
    scope_url  = config[:scope_url]
    put_policy = Qiniu.PutPolicy.build(scope_name)
    req = Qiniu.Uploader.upload(put_policy, conn["path"])
    file_name = req.body["key"]
    scope_url <> "/" <> file_name
  end

  @doc """
  传图片或者文件,返回 服务器图片地址, base64传入
  """
  def upload(str_base64) when is_binary(str_base64) do
    path = "./#{Enum.take_random(?0..?9, 4)}"
    {:ok, decode64} = Base.decode64(str_base64)
    File.write(path, decode64, [:binary])
    config = Application.get_env :xin, :qiniu
    scope_name = config[:scope_name]
    scope_url  = config[:scope_url]
    put_policy = Qiniu.PutPolicy.build(scope_name)
    req = Qiniu.Uploader.upload(put_policy, path)
    file_name = req.body["key"]
    File.rm!(path)
    scope_url <> "/" <> file_name
  end

end
