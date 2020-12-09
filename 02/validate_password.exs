defmodule ValidatePassword do
  def perform(system_args) do
    {opts, [input_file_path], _errors} = OptionParser.parse(system_args, strict: [p: :string])

    part = Keyword.get(opts, :p, "1")
    IO.puts("Validating passwords given in file: #{input_file_path} for part #{part}")

    input_file_path
    |> read_file()
    |> count_valid_pswd(part)
  end

  defp read_file(path) do
    path
    |> File.stream!()
    |> Enum.map(&String.trim(&1))
  end

  defp count_valid_pswd(lines, part) do
    Enum.reduce(lines, 0, fn line, sum -> if is_valid?(line, part), do: sum + 1, else: sum end)
  end

  defp is_valid?(line, part) do
    %{"left" => left, "right" => right, "char" => char, "pswd" => pswd} =
      Regex.named_captures(~r/\A(?<left>\d+)-(?<right>\d+)\s+(?<char>\S):\s*(?<pswd>\S+)\z/, line)

    unless part == "2" do
      occurences = String.graphemes(pswd) |> Enum.count(&(&1 == char))
      int(left) <= occurences and occurences <= int(right)
    else
      at_left? = String.at(pswd, int(left) - 1) == char
      at_right? = String.at(pswd, int(right) - 1) == char

      xor(at_left?, at_right?)
    end
  end

  defp int(num), do: String.to_integer(num)

  defp xor(left, right) do
    (left or right) and not (left and right)
  end
end

total_valid = System.argv() |> ValidatePassword.perform()
IO.puts("Total valid passwords = #{total_valid}")
