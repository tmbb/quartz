defmodule Quartz.Utilities do
  @moduledoc false

  @basename_characters (Enum.into(?0..?9, []) ++ Enum.into(?a..?z, []))

  def with_tmp_file!(suffix, fun) do
    charlist = Enum.map(1..32, fn _ -> Enum.random(@basename_characters) end)
    basename = to_string(charlist) <> suffix
    tmp_file = Path.join([System.tmp_dir!(), basename])
    try do
      fun.(tmp_file)
    after
      File.rm(tmp_file)
    end
  end
end
