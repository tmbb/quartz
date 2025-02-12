defmodule Quartz.FontHashes do
  def hash(binary) do
   Base.encode16(:crypto.hash(:sha256, binary), case: :lower)
  end

  def run() do
    fonts_dir =
      __DIR__
      |> Path.join("../../quartz_fonts")
      |> Path.expand()

    rel_font_paths =
      fonts_dir
      |> File.ls!()
      |> Enum.reject(&File.dir?/1)
      |> Enum.reject(fn file -> String.ends_with?(file, ".txt") end)
      |> Enum.sort()

    abs_font_paths = Enum.map(rel_font_paths, fn file ->
      Path.join(fonts_dir, file)
    end)

    hashes =
      for {rel, abs} <- Enum.zip(rel_font_paths, abs_font_paths) do
        font_hash = abs |> File.read!() |> hash()
        {rel, font_hash}
      end

    hashes_file =
      __DIR__
      |> Path.join("../priv/font_hashes.exs")
      |> Path.expand()

    File.write!(hashes_file, inspect(hashes, pretty: true))
  end
end

Quartz.FontHashes.run()
