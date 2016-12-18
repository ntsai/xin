defmodule Xin.Ecto.Timestamps do
  @moduledoc """
  Provides a simple way to use Timex with Ecto timestamps.
  # Example
  ```
  defmodule User do
    use Ecto.Schema
    use Xin.Ecto.Timestamps
    schema "user" do
      field :name, :string
      timestamps
    end
  ```
  By default this will generate a timestamp with seconds precision. If you
  would like to generate a timestamp with more precision you can pass the
  option `usec: true` to the macro.
  ```
  use Timex.Ecto.Timestamps, usec: true
  ```
  For potentially easier use with Phoenix, add the following in `web/web.ex`:
  ```elixir
  def model do
    quote do
      use Ecto.Schema
      use Xin.Ecto.Timestamps
    end
  end
  ```
  This will bring Timex timestamps into scope in all your models
  """

  defmacro __using__(opts) do
    args = case Keyword.fetch(opts, :usec) do
      {:ok, true} -> [:usec]
      _           -> [:sec]
    end
    quote do
      @timestamps_opts [autogenerate: {Xin.Ecto.DateTime, :autogenerate, unquote(args)}]
    end
  end
end

defmodule Xin.Ecto.DateTime do

  def autogenerate(precision \\ :sec)
  def autogenerate(:sec) do
    {date, {h, m, s}} = :erlang.localtime
    erl_load({date, {h, m, s, 0}})
  end
  def autogenerate(:usec) do
    timestamp = {_, _, usec} = :os.timestamp
    {date, {h, m, s}} = :calendar.now_to_local_time(timestamp)
    erl_load({date, {h, m, s, usec}})
  end

  def erl_load({{year, month, day}, {hour, min, sec, usec}}) do
    %Ecto.DateTime{
      year: year,
      month: month,
      day: day,
      hour: hour,
      min: min,
      sec: sec,
      usec: usec
    }
  end
  def local(), do: Ecto.DateTime.cast!(Timex.local) 
end

defmodule Xin.Ecto.Date do
  def local(), do: Ecto.Date.cast!(Timex.local) 
end