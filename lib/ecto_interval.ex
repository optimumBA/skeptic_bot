defmodule EctoInterval do
  @moduledoc """
  Ecto type for PostgreSQL interval type
  """

  if macro_exported?(Ecto.Type, :__using__, 1) do
    use Ecto.Type
  else
    @behaviour Ecto.Type
  end

  @impl Ecto.Type
  def type, do: Postgrex.Interval

  @impl Ecto.Type
  def cast(%{"months" => months, "days" => days, "secs" => secs}) do
    do_cast(months, days, secs)
  end

  def cast(%{months: months, days: days, secs: secs}) do
    do_cast(months, days, secs)
  end

  def cast(_interval) do
    :error
  end

  defp do_cast(months, days, secs) do
    months = to_integer(months)
    days = to_integer(days)
    secs = to_integer(secs)
    {:ok, %{months: months, days: days, secs: secs}}
  rescue
    _reason -> :error
  end

  defp to_integer(arg) when is_binary(arg) do
    String.to_integer(arg)
  end

  defp to_integer(arg) when is_integer(arg) do
    arg
  end

  @impl Ecto.Type
  def load(%{months: months, days: days, secs: secs}) do
    {:ok, %Postgrex.Interval{months: months, days: days, secs: secs}}
  end

  @impl Ecto.Type
  def dump(%{months: months, days: days, secs: secs}) do
    {:ok, %Postgrex.Interval{months: months, days: days, secs: secs}}
  end

  def dump(%{"months" => months, "days" => days, "secs" => secs}) do
    {:ok, %Postgrex.Interval{months: months, days: days, secs: secs}}
  end
end

defimpl String.Chars, for: [Postgrex.Interval] do
  import Kernel, except: [to_string: 1]

  @spec to_string(Postgrex.Interval.t()) :: String.t()
  def to_string(%{:months => months, :days => days, :secs => secs}) do
    m =
      if months === 0 do
        ""
      else
        " #{months} months"
      end

    d =
      if days === 0 do
        ""
      else
        " #{days} days"
      end

    s =
      if secs === 0 do
        ""
      else
        " #{secs} seconds"
      end

    if months === 0 and days === 0 and secs === 0 do
      "<None>"
    else
      "Every#{m}#{d}#{s}"
    end
  end
end

defimpl Inspect, for: [Postgrex.Interval] do
  @spec inspect(Postgrex.Interval.t(), Inspect.Opts.t()) :: String.t()
  def inspect(inv, _opts) do
    inspect(Map.from_struct(inv))
  end
end
