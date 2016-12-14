#短信模块
defmodule Xin.Sms do
  @moduledoc """
  短信插件(云片)

  配置 config.exs
  config :xin, :sms,
    api_key: "973ff3b797b1cadc7ca2xxxxxxxd8",
    api_url: "https://sms.yunpian.com/v2/sms/single_send.json",
  """

  @doc """
  随机验证码,默认四位数字
  """
  def code(num \\ 4) do
    c = Enum.take_random ?0..?9,num
    "#{c}"
  end

  @doc """
  发送短信,dev: 是否测试环境，默认 8888
  """
  def get_code(), do: if Mix.env == :dev, do: "8888", else: code
  def get_code(str) when is_binary(str), do: str
  def get_code(env) when is_atom(env), do: if env == :dev, do: "8888", else: code

  #检查手机号码 renturn {result, error}
  def is_phone?(mobile) do
    Xin.Help.is_phone?(mobile)
  end

  @doc """
  发送短信，目前支持云片 return {result, error}
  """
  def send(mobile, text) do
    {result, error} = is_phone?(mobile)
    if result do
      config = Application.get_env :xin, :sms
      api_key = config[:api_key]
      api_url  = config[:api_url]
      data = [apikey: api_key, mobile: mobile, text: text]
      HTTPoison.post(api_url, {:form,  data}, %{"Content-type" => "application/x-www-form-urlencoded"})
    end
    {result, error}
  end

end
