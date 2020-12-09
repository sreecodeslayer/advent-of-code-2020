defmodule Report do
  def fix(system_args) do
    {opts, [input_file_path], _errors} = OptionParser.parse(system_args, strict: [p: :string])

    part = Keyword.get(opts, :p, "1")
    IO.puts("Repairing report given in file: #{input_file_path} for part #{part}")

    input_file_path
    |> read_file()
    |> find_2020_pair(part)
    |> product()
  end

  defp read_file(path) do
    path
    |> File.stream!()
    |> Enum.reduce([], fn line, acc ->
      case String.trim(line) do
        "" -> acc
        num -> [int(num) | acc]
      end
    end)
  end

  defp find_2020_pair(expenses, part) do
    do_find_pairs(expenses, part, 2020)
  end

  defp do_find_pairs([], _, _), do: nil

  defp do_find_pairs([num1 | remaining_expenses], "1", total) do
    case Enum.find(remaining_expenses, fn exp -> num1 + exp == total end) do
      nil -> do_find_pairs(remaining_expenses, "1", total)
      found -> {num1, found}
    end
  end

  defp do_find_pairs([num1 | remaining_expenses], "2", total) do
    case do_find_pairs(remaining_expenses, "1", total - num1) do
      nil -> do_find_pairs(remaining_expenses, "2", total)
      {num2, num3} -> {num1, num2, num3}
    end
  end

  defp int(line), do: line |> String.trim() |> String.to_integer()

  defp product({a, b, c}) do
    IO.puts("#{a} + #{b} + #{c} = #{a + b + c}")
    a * b * c
  end

  defp product({a, b}) do
    IO.puts("#{a} + #{b} = #{a + b}")
    a * b
  end
end

product = System.argv() |> Report.fix()
IO.puts("Product = #{product}")
