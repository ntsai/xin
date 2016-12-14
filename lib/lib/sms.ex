#短信模块
defmodule Xin.Lib.Sms do
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
  def get_code(dev), do: if dev, do: "8888", else: code

  #检查手机号码
  def check(phone) do
    Xin.Help.is_phone?(phone)
  end

  @doc """
  发送短信，目前支持云片
  """
  def send(mobile, text) do
    config = Application.get_env :xin, :sms
    api_key = config[:api_key]
    api_url  = config[:api_url]
    data = [apikey: api_key, mobile: mobile, text: text]
    HTTPoison.start
    HTTPoison.post(api_url, {:form,  data}, %{"Content-type" => "application/x-www-form-urlencoded"})
  end

end
