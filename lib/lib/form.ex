defmodule Xin.Form do

  @moduledoc """
  表单验证模块

  defmodule FormTest do
    use Xin.Form

    form "user" do
      filed :name,   :string,  required: true, label: "姓名"
      filed :passwd, :string,  required: true, label: "密码"
      filed :img,    :img, label: "图片名"

      def verfiy(:img, _data, _conn) do
        {:img, true, "", "wahahahha"}
      end
    end
  end
  """
  
  defmacro form(do: block) do
    quote do
      form nil do
        unquote(block)
      end
    end
  end

  defmacro form(mod, do: block) do

    quote do
      Module.put_attribute __MODULE__, :form_filed, verfiy_struct(unquote(mod))

      unquote(block)

      def verify_form(conn) do
        Enum.reduce(@form_filed, %{req: true, data: %{}, errors: []}, fn(form_filed_data, acc) ->
            {filed_name, filed_data}  = form_filed_data
            {name, req, errors, value} = verfiy(filed_name, filed_data, conn)
            acc_req = unless req, do: false, else: acc[:req]
            acc_data = Map.put(acc[:data], Atom.to_string(filed_name), value)
            acc_errors = if errors != "", do: acc[:errors] ++ [errors], else: acc[:errors]
            %{req: acc_req, data: acc_data, errors: acc_errors}
        end)

      end

      defp verfiy(name, data, conn) do
        value = Map.get(conn, Atom.to_string(name))
        {req, errors, value} = verfiy_field(data[:opt], data[:type], value)
        label = if data[:opt][:label], do: data[:opt][:label], else: name
        errors = if errors != "", do: "#{label}: #{errors}", else: ""
        {name, req, errors, value}
      end

    end
  end

  defmacro filed(name, type, opt \\ []) do
    quote do
      data = %{name: unquote(name), type: unquote(type), opt: unquote(opt)}
      form_filed = Map.put(@form_filed, unquote(name), data)
      Module.put_attribute __MODULE__, :form_filed, form_filed
    end
  end

  defmacro __using__(_) do
    quote do
      import Xin.Lib.Form
      @form_filed %{}
    end
  end

  def verfiy_field(opt, type, value) do
    value = if opt[:default] && value == nil, do: opt[:default], else: value

    {req ,errors} = if opt[:required] && value == nil do
                      {false, "字段#{opt[:name]}必填"}
                    else
                      {true, ""}
                    end
    {req ,errors} = if req && value do
                      verfiy_field_type(value, type)
                    else
                      {req ,errors}
                    end
    {req, errors, value}
  end

  @errors_type_msg [string: "字符", integer: "整数", boolean: "布尔值", map: "结构", list: "列表", decimal: "浮点数"]
  def verfiy_field_type(value, type) do
    req = case type do
          :id ->
            is_integer(value)
          :string ->
            is_binary(value)
          :integer ->
            is_integer(value)
          :boolean ->
            is_boolean(value)
          :number ->
            is_number(value)
          :map ->
            is_map(value)
          :list ->
            is_list(value)
          :decimal ->
            is_float(value)
          _ ->
            true
          end
    errors = unless req, do: "必须是#{@errors_type_msg[type]}", else: ""
    {req, errors} = if type == :mobile do
                      Xin.Help.is_phone?(value)
                    else
                      {req, errors}
                    end
    {req, errors}
  end

  def verfiy_struct(mod) do
    data = mod.__schema__(:types)
    Enum.reduce(data, %{}, fn({filed_name, type}, acc) ->
      Map.put(acc, filed_name, %{name: filed_name, type: type, opt: []})
    end)
  end
end

