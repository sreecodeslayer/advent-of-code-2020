defmodule Passport do
  @required_keys ["byr", "cid", "ecl", "eyr", "hcl", "hgt", "iyr", "pid"]
  def validate(system_args) do
    {_opts, [input_file_path], _errors} = OptionParser.parse(system_args, strict: [])
    IO.puts("Traversing given tree map in file: #{input_file_path}")

    input_file_path
    |> read_file()
    |> count_valid_passports()
  end

  defp read_file(path) do
    chunk_by_empty_new_line = fn element, acc ->
      if element == "\n" do
        {:cont, acc, []}
      else
        {:cont, [element | acc]}
      end
    end

    after_chunk = fn
      [] -> {:cont, []}
      acc -> {:cont, acc, []}
    end

    path
    |> File.stream!()
    |> Stream.chunk_while([], chunk_by_empty_new_line, after_chunk)
  end

  defp count_valid_passports(passports) do
    Enum.reduce(passports, 0, fn psprt, sum ->
      if is_passport_valid?(psprt), do: sum + 1, else: sum
    end)
  end

  defp is_passport_valid?(passport) do
    all_keys =
      passport
      |> Enum.join(" ")
      |> String.split(" ", trim: true)
      |> Enum.map(fn kv -> String.split(kv, ":") |> hd end)
      |> Enum.sort()

    case @required_keys -- all_keys do
      ["cid"] -> true
      [] -> true
      _ -> false
    end
  end
end

total = System.argv() |> Passport.validate()
IO.puts("Total valid passports = #{inspect(total)}")
