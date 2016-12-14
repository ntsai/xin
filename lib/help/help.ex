defmodule Xin.Help do
  @moduledoc """
  常用帮助库
  """

  @doc """
  判断 手机号码是否正确, return {bool, ""}
  """
  def is_phone?(phone) do
    if is_binary(phone) do
      err = ""
      err = if String.length(phone) != 11, do: err <> "手机号码不足11位,", else: err
      err = if String.first(phone) != "1", do: err <> "手机首位必须为1,", else: err
      is_num = Enum.find(String.codepoints(phone), fn(x) -> String.contains?("0123456789",x) == false end)
      err = if is_num,  do: err <> "手机号码必须是数字", else: err
      {err == "", err}
    else
      {false, "必须是字符串"}
    end
  end

end
