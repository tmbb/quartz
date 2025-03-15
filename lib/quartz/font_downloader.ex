defmodule Quartz.FontDownloader do
  require Logger

  @font_repo_commit_hash "229208509209e61c3b2c1bd13605aa4a3c78b021"

  def artifact_url() do
    "https://github.com/tmbb/quartz_fonts/archive/#{@font_repo_commit_hash}.zip"
  end

  def font_hash(font_path) do
    binary = File.read!(font_path)
    Base.encode16(:crypto.hash(:sha256, binary), case: :lower)
  end

  def default_fonts() do
    path = Path.join(:code.priv_dir(:quartz), "font_hashes.exs")

    {:ok, pairs} =
      path
      |> File.read!()
      |> Code.string_to_quoted()

    pairs
  end

  def fonts_to_download(fonts_dir) do
    Enum.reject(default_fonts(), fn {font, expected_hash} ->
      abs_font_path = Path.join(fonts_dir, font)
      File.exists?(abs_font_path) and font_hash(abs_font_path) == expected_hash
    end)
  end

  def maybe_download_fonts() do
    fonts_dir = Path.join(:code.priv_dir(:quartz), "fonts")
    fonts = fonts_to_download(fonts_dir)

    if fonts != [] do
      download_fonts(
        fonts,
        artifact_url(),
        fonts_dir
      )
    end

    :ok
  end

  def download_fonts(fonts, url, dst_dir) do
    Logger.debug("Downloading fonts from #{url}")

    zip_archive = fetch_file!(url)

    random_suffix = 1..100_000_000 |> Enum.random() |> to_string()
    unpack_dir = "unpacked_#{random_suffix}"
    tmp_dir = System.tmp_dir!() |> Path.join(unpack_dir)

    try do
      unpacked =
        :zip.extract(zip_archive, [
          cwd: to_charlist(tmp_dir)
        ])

      downloaded_font_files =
        case unpacked do
          {:ok, files} ->
            Enum.map(files, &to_string/1)

          other ->
            raise "couldn't unpack archive: #{inspect(other)}"
        end

      {font_files, _hashes} = Enum.unzip(fonts)

      for src_path <- downloaded_font_files do
        file = Path.basename(src_path)
        # This is quadractic but it's a small number of fonts,
        # so it probably doesn't matter
        if file in font_files do
          dst_path = Path.join(dst_dir, file)
          File.cp!(src_path, dst_path)
        end
      end

      case length(font_files) do
        1 -> Logger.debug("Added 1 font file.")
        more_than_one -> Logger.debug("Added #{more_than_one} font files.")
      end
    after
      File.rm_rf!(tmp_dir)
    end
  end

  defp fetch_file!(url, retry \\ true) do
    {:ok, _} = Application.ensure_all_started(:inets)
    {:ok, _} = Application.ensure_all_started(:ssl)

    case {retry, do_fetch(url)} do
      {_, {:ok, {{_, 200, _}, _headers, body}}} ->
        body

      {true, {:error, {:failed_connect, [{:to_address, _}, {inet, _, reason}]}}}
      when inet in [:inet, :inet6] and
             reason in [:ehostunreach, :enetunreach, :eprotonosupport, :nxdomain] ->
        :httpc.set_options(ipfamily: fallback(inet))
        fetch_file!(url, false)

      other ->
        raise """
        couldn't fetch #{url}: #{inspect(other)}
        """
    end
  end

  defp fallback(:inet), do: :inet6
  defp fallback(:inet6), do: :inet

  defp do_fetch(url) do
    scheme = URI.parse(url).scheme
    url = String.to_charlist(url)

    :httpc.request(
      :get,
      {url, []},
      [
        ssl: [
          verify: :verify_peer,
          # https://erlef.github.io/security-wg/secure_coding_and_deployment_hardening/inets
          cacerts: :public_key.cacerts_get(),
          depth: 2,
          customize_hostname_check: [
            match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
          ]
        ]
      ]
      |> maybe_add_proxy_auth(scheme),
      body_format: :binary
    )
  end

  defp proxy_for_scheme("http") do
    System.get_env("HTTP_PROXY") || System.get_env("http_proxy")
  end

  defp proxy_for_scheme("https") do
    System.get_env("HTTPS_PROXY") || System.get_env("https_proxy")
  end

  defp maybe_add_proxy_auth(http_options, scheme) do
    case proxy_auth(scheme) do
      nil -> http_options
      auth -> [{:proxy_auth, auth} | http_options]
    end
  end

  defp proxy_auth(scheme) do
    with proxy when is_binary(proxy) <- proxy_for_scheme(scheme),
         %{userinfo: userinfo} when is_binary(userinfo) <- URI.parse(proxy),
         [username, password] <- String.split(userinfo, ":") do
      {String.to_charlist(username), String.to_charlist(password)}
    else
      _ -> nil
    end
  end
end
