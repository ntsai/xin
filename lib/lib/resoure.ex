defmodule Xin.Rest do

  @doc """
    路由宏
  """
  defmacro resful(path, mod) do
    quote do
      # get unquote(path), unquote(mod), :index
      # get unquote(path)  <> "/detail/:id", unquote(mod), :show
      # post unquote(path) <> "/update", unquote(mod), :update
      # post unquote(path) <> "/create", unquote(mod), :create
      # post unquote(path) <> "/delete", unquote(mod), :delete
    end
  end

  defmacro __using__(mod) do
    quote do
      use unquote(mod), :controller
      import Xin.Lib.Rest
      import Ecto.Changeset

      @auth nil
      @model nil
      @method ""
      @form nil
      @page_size 20
      @order_by [desc: :id]
      @select []
      @where :say
    end    
  end

  defmacro router(name) do
    quote do
      router unquote(name) do
      end
    end
  end

  @doc """
    模块资源配置宏
  """
  defmacro router(name, do: block) do
    IO.puts name
    quote do

      if String.contains?(@method, "l"),  do: unquote quote_view("l")
      if String.contains?(@method, "c"),  do: unquote quote_view("c")
      if String.contains?(@method, "u"),  do: unquote quote_view("u")
      if String.contains?(@method, "r"),  do: unquote quote_view("r")
      if String.contains?(@method, "d"),  do: unquote quote_view("d")
      
      unquote(block)
    end
  end

  defp quote_view("l") do
    quote do
      def show(conn, params) do
        json conn, %{code: 200}
      end
    end
  end

  defp quote_view("c") do
    quote do
      def create(conn, params) do
        json conn, %{code: 200}
      end
    end
  end

  defp quote_view("u") do
    quote do
      def update(conn, params) do
        json conn, %{code: 200}
      end
    end
  end

  defp quote_view("r") do
    quote do
      def detail(conn, params) do
        json conn, %{code: 200}
      end
    end
  end

  defp quote_view("d") do
    quote do
      def delete(conn, params) do
        json conn, %{code: 200}
      end
    end
  end

end


defmodule RestTest do

end