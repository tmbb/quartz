defmodule Quartz.Math.UnicodeDatabase do
  @moduledoc false

  defstruct code_to_name: %{},
            name_to_code: %{},
            exceptions: %{}

  def fetch_name_from_code!(db, code) when is_integer(code) do
    Map.fetch!(db.code_to_name, code)
  end

  def fetch_name_from_hex_code!(db, hex_code) when is_binary(hex_code) do
    {code, ""} = Integer.parse(hex_code, 16)
    fetch_name_from_code!(db, code)
  end

  def fetch_code_from_name!(db, name) when is_binary(name) do
    case Map.fetch(db.name_to_code, name) do
      {:ok, value} ->
        value

      :error ->
        new_name = String.replace(name, "MATHEMATICAL ", "")

        case Map.fetch(db.name_to_code, new_name) do
          {:ok, value} ->
            value

          :error ->
            cond do
              String.contains?(name, "FRAKTUR") ->
                black_name = String.replace(name, "MATHEMATICAL FRAKTUR", "BLACK-LETTER")
                Map.fetch!(db.name_to_code, black_name)

              name == "MATHEMATICAL ITALIC SMALL H" ->
                new_name = "PLANCK CONSTANT"
                Map.fetch!(db.name_to_code, new_name)

              true ->
                raise "Invalid character name: '#{name}'"
            end
        end
    end
  end

  def build() do
    path = Path.join(:code.priv_dir(:quartz), "UnicodeData.txt")

    name_to_code =
      path
      |> File.read!()
      |> String.split("\n")
      |> Enum.reject(fn line -> line == "" end)
      |> Enum.map(fn line -> line |> String.split(";") |> Enum.take(2) end)
      |> Enum.map(fn [code, name] ->
        {i_code, ""} = Integer.parse(code, 16)
        {name, i_code}
      end)

    code_to_name = for {name, code} <- name_to_code, do: {code, name}

    %__MODULE__{
      code_to_name: Enum.into(code_to_name, %{}),
      name_to_code: Enum.into(name_to_code, %{})
    }
  end
end
