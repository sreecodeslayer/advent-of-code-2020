defmodule Report do
  def fix(system_args) do
    {_opts, [input_file_path], _errors} = OptionParser.parse(system_args, strict: [])

    input_file_path
    |> read_file()
    |> find_2020_pair()
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

  defp find_2020_pair([start | remaining_expenses]) do
    case Enum.find(remaining_expenses, fn exp -> start + exp == 2020 end) do
      nil -> find_2020_pair(remaining_expenses)
      found -> {start, found}
    end
  end

  defp int(line), do: line |> String.trim() |> String.to_integer()

  defp product({a, b}) do
    IO.puts("#{a} + #{b} = #{a + b}")
    a * b
  end
end

product = System.argv() |> Report.fix()
IO.puts("Product = #{product}")
