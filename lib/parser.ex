defmodule MT940.Parser do
  use Timex

  def parse(raw) when is_binary(raw) do
    raw
    |> String.strip
    |> String.split(Regex.compile!("(\R?):\\d{1,2}\\w?:()"), on: :all_but_first, trim: true)
    |> Stream.map(&String.strip/1)
    |> Stream.chunk(2)
    |> Stream.map(fn [k, v] -> {k |> remove_newline |> String.to_atom(), split(k, v)} end)
    |> Enum.into(Keyword.new)
  end


  defp split(":25:", v) do
    case v |> String.contains?("/") do
      true  -> ~r/^(\d{8}|\w{8,11})\/(\d{1,23})(\D{3})?$/
      false -> ~r/^(.+)(\D{3})?$/
    end
    |> Regex.run(v, capture: :all_but_first)
    |> List.to_tuple
  end


  defp split(":28C:", v) do
    ~r/^(\d+)\/?(\d+)?$/
    |> Regex.run(v, capture: :all_but_first)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple
  end


  defp split(":60" <> <<_>> <> ":", v) do
    v |> remove_newline |> balance
  end


  defp split(":61:", v) do
    l = ~r/^(\d{6})(\d{4})?(C|RC|D|RD)(\D)?([0-9,]{4,15})(\w{4})(NONREF|.{1,22})(\/\/)?(\w{0,16})?([\s\R]{1,2})?(.{0,34})?$/
    |> Regex.run(v, capture: :all_but_first)
    |> List.update_at(4, &String.lstrip(&1, ?0))
    |> List.update_at(0, &DateFormat.parse!(&1, "{YY}{M}{D}"))

    booking_date = l |> Enum.at(0)

    case booking_date do
      nil -> l
      _   -> l |> List.update_at(1, &DateFormat.parse!("#{booking_date.year}#{&1}", "{YYYY}{M}{D}"))
    end
    |> List.to_tuple
  end


  defp split(":86:", v) do
    s = ~r/^(\d{3})(\D)/
    |> Regex.run(v, capture: :all_but_first)

    case s do
      [code, separator] -> 
        fields = v
        |> remove_newline
        |> String.split(Regex.compile!("(^\\d{3})?(\\#{separator})\\d{2}()"), on: :all_but_first, trim: true)
        |> Stream.chunk(2)
        |> Stream.map(fn [k, v] -> {String.to_integer(k), v} end)
        |> Enum.into(HashDict.new)
        {code, fields}
      _ ->
        Regex.split(~r/\R/, v) |> Enum.at(0)
    end
  end


  defp split(":62" <> <<_>> <> ":", v) do
    v |> remove_newline |> balance
  end


  defp split(":90" <> <<_>> <> ":", v) do
    ~r/^(\d{1,5})(\w{3})([0-9,]{1,15})$/
    |> Regex.run(v, capture: :all_but_first)
    |> List.to_tuple
  end


  defp split(_, v) when is_binary(v) do
    v
  end


  defp balance(v) do
    ~r/^(\w{1})(\d{6})(\w{3})([0-9,]{1,15}).*$/
    |> Regex.run(v, capture: :all_but_first)
    |> List.update_at(1, &DateFormat.parse!(&1, "{YY}{M}{D}"))
    |> List.update_at(3, &String.lstrip(&1, ?0))
    |> List.to_tuple
  end


  defp remove_newline(string) when is_binary(string) do
    ~r(\R) |> Regex.replace(string, "")
  end
end
