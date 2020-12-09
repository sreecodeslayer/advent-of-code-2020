defmodule Trajectory do
  @tree "#"

  def walk(system_args) do
    {opts, [input_file_path], _errors} = OptionParser.parse(system_args, strict: [p: :string])
    part = Keyword.get(opts, :p, "1")
    IO.puts("Traversing given tree map in file: #{input_file_path} for part #{part}")

    input_file_path
    |> read_file()
    |> do_the_walk(part)
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

  defp do_the_walk(area_map, "1") do
    count_trees_in_slope(area_map, {3, 1})
  end

  defp do_the_walk(area_map, "2") do
    slopes = [{1, 1}, {3, 1}, {5, 1}, {7, 1}, {1, 2}]
    Enum.reduce(slopes, 1, fn slope, acc -> count_trees_in_slope(area_map, slope) * acc end)
  end

  defp count_trees_in_slope([first_line | _] = area_map, {slope_x, slope_y}) do
    total_rows = length(area_map)
    width = length(first_line)

    # top left of map
    origin = {0, 0}

    stream =
      Stream.unfold(origin, fn {x, y} ->
        next_right = rem(x + slope_x, width)
        next_down = y + slope_y

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
IO.puts("Total = #{total}")
