defmodule Trajectory do
  @tree "#"

  def walk(system_args) do
    {_opts, [input_file_path], _errors} = OptionParser.parse(system_args, strict: [])
    IO.puts("Traversing given tree map in file: #{input_file_path}")

    input_file_path
    |> read_file()
    |> do_the_walk
  end

  defp read_file(path) do
    area_map =
      path
      |> File.stream!()
      |> Enum.reduce([], fn line, acc ->
        case String.trim(line) do
          "" -> acc
          line -> [line |> String.trim() |> String.graphemes() | acc]
        end
      end)

    Enum.reverse(area_map)
  end

  defp do_the_walk([first_line | _] = area_map) do
    total_rows = length(area_map)
    width = length(first_line)

    # top left of map
    origin = {0, 0}

    stream =
      Stream.unfold(origin, fn {x, y} ->
        next_right = rem(x + 3, width)
        next_down = y + 1

        next = {next_right, next_down}

        if next_down < total_rows do
          {next, next}
        else
          # stop unfold
          nil
        end
      end)

    Enum.count(stream, fn {pos, row} ->
      area_map |> Enum.at(row) |> Enum.at(pos) == @tree
    end)
  end
end

total = System.argv() |> Trajectory.walk()
IO.puts("Total trees encountered = #{total}")
