defmodule ValidatePassword do
  def perform(system_args) do
    {_opts, [input_file_path], _errors} = OptionParser.parse(system_args, strict: [])

    IO.puts("Validating passwords given in file: #{input_file_path}")

    input_file_path
    |> read_file()
    |> count_valid_pswd()
  end

  defp read_file(path) do
    path
    |> File.stream!()
    |> Enum.map(&String.trim(&1))
  end

  defp count_valid_pswd(lines) do
    Enum.reduce(lines, 0, fn line, sum -> if is_valid?(line), do: sum + 1, else: sum end)
  end

  def is_valid?(line) do
    %{"min" => min, "max" => max, "char" => char, "pswd" => pswd} =
      Regex.named_captures(~r/\A(?<min>\d+)-(?<max>\d+)\s+(?<char>\S):\s*(?<pswd>\S+)\z/, line)

    occurences = String.graphemes(pswd) |> Enum.count(&(&1 == char))
    int(min) <= occurences and occurences <= int(max)
  end

  defp int(num), do: String.to_integer(num)
end

total_valid = System.argv() |> ValidatePassword.perform()
IO.puts("Total valid passwords = #{total_valid}")
