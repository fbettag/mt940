defmodule MT940.StatementLine do
  @moduledoc ~S"""
  Statement Line
  """

  import Helper
  use Timex

  defstruct [
    :modifier,
    :content,
    :value_date,
    :entry_date,
    :funds_code,
    :amount,
    :swift_code,
    :reference,
    :transaction_description
  ]

  @type t :: %__MODULE__{}

  use MT940.Field

  defp parse_content(result = %__MODULE__{content: content}) do
    ~r/^(\d{6})(\d{4})?(CR|C|D|RC|RD)\D?(\d{1,12},\d{0,2})((?:N|F).{3})(NONREF|.{0,16}).*/
    |> Regex.run(content, capture: :all_but_first)
    |> parse_matches(result)
  end

  defp parse_matches(nil, result = %__MODULE__{}), do: result
  defp parse_matches(matches, result = %__MODULE__{}) do
    value_date = case matches |> Enum.at(0) |> Timex.parse("{YY}{M}{D}") do
      {:ok, vd} -> vd
      _ -> Timex.now()
    end
    entry_date = case matches |> Enum.at(1) do
      "" -> nil
      _  -> "#{value_date.year}#{Enum.at(matches, 1)}" |> Timex.parse!("{YYYY}{M}{D}")
    end
    funds_code = case matches |> Enum.at(2) do
      "C"  -> :credit
      "CR"  -> :credit
      "D"  -> :debit
      "RC" -> :return_credit
      "RD" -> :return_debit
    end
    amount     = matches |> Enum.at(3) |> convert_to_decimal
    swift_code = matches |> Enum.at(4)
    reference  = matches |> Enum.at(5)
    transaction_description = case matches |> Enum.at(6) do
      "" -> nil
      _  -> matches |> Enum.at(6)
    end

    %__MODULE__{result |
      value_date:              value_date,
      entry_date:              entry_date,
      funds_code:              funds_code,
      amount:                  amount,
      swift_code:              swift_code,
      reference:               reference,
      transaction_description: transaction_description
    }
  end

end
