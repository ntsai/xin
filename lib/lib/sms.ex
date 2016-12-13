#短信模块
defmodule Xin.Lib.Sms do

  @doc """
  短信插件(云片)
  
  配置 config.exs
  config config :xin, :sms,
    api_key: "973ff3b797b1cadc7ca2xxxxxxxd8",
    api_url: "https://sms.yunpian.com/v2/sms/single_send.json",
  """

  #随机验证码,默认四位数字
  def code(num \\ 4) do
    c = Enum.take_random ?0..?9,num
    "#{c}"
  end

  #发送短信,dev: 是否测试环境，默认 8888
  def get_code(dev), do: if dev, do: "8888", else: code

  #检查手机号码
  def check(phone) do
    err = ""
    if String.length(phone) != 11, do: err = err <> "手机号码不足11位," 
    if String.first(phone) != "1", do: err = err <> "手机首位必须为1,"

    is_num = Enum.find(String.codepoints(phone), fn(x) -> String.contains?("0123456789",x) == false end)
    if is_num,  do: err = err <> "手机号码必须是数字"
    {err == "", err} 
  end

  #云片短信发送
  def send(mobile, text) do
    config = Application.get_env :xin, :sms
    api_key = config[:api_key]
    api_url  = config[:api_url]
    data = [apikey: api_key, mobile: mobile, text: text]
    HTTPoison.start
    HTTPoison.post(api_url, {:form,  data}, %{"Content-type" => "application/x-www-form-urlencoded"})
  end

end