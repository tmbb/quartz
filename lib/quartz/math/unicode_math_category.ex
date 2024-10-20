defmodule Quartz.Math.UnicodeMathCategory do
  @moduledoc false
  defstruct name: nil,
            slug: nil,
            unicode: nil,
            prefix: nil,
            groups: [],
            function_builder: {__MODULE__, :build_character_function, []}

  def build_character_function(unicode_char, _category, _arguments) do
    hex_code = Integer.to_string(unicode_char.code, 16)
    func = String.to_atom(unicode_char.short_name)

    quote do
      @doc """
      Mathematical character #{unquote(<<unicode_char.code::utf8>>)} (U+#{unquote(hex_code)})
      """
      def unquote(func)(opts \\ []) do
        Quartz.Text.Tspan.new(
          unquote(<<unicode_char.code::utf8>>),
          Quartz.Config.get_math_character_attributes(opts)
        )
      end
    end
  end

  @alpha_greek_num_name_to_code_map %{
    "SMALL O" => 111,
    "CAPITAL V" => 86,
    "SMALL C" => 99,
    "CAPITAL K" => 75,
    "CAPITAL X" => 88,
    "CAPITAL A" => 65,
    "SMALL U" => 117,
    "SMALL H" => 104,
    "CAPITAL O" => 79,
    "CAPITAL Y" => 89,
    "SMALL B" => 98,
    "CAPITAL L" => 76,
    "SMALL K" => 107,
    "CAPITAL P" => 80,
    "SMALL A" => 97,
    "CAPITAL S" => 83,
    "SMALL M" => 109,
    "CAPITAL Z" => 90,
    "SMALL Z" => 122,
    "SMALL W" => 119,
    "CAPITAL T" => 84,
    "CAPITAL I" => 73,
    "SMALL R" => 114,
    "SMALL V" => 118,
    "SMALL J" => 106,
    "CAPITAL C" => 67,
    "SMALL X" => 120,
    "CAPITAL M" => 77,
    "CAPITAL G" => 71,
    "CAPITAL W" => 87,
    "SMALL Y" => 121,
    "SMALL D" => 100,
    "SMALL I" => 105,
    "CAPITAL Q" => 81,
    "CAPITAL N" => 78,
    "SMALL N" => 110,
    "CAPITAL B" => 66,
    "CAPITAL F" => 70,
    "CAPITAL D" => 68,
    "CAPITAL E" => 69,
    "SMALL S" => 115,
    "SMALL Q" => 113,
    "SMALL P" => 112,
    "CAPITAL H" => 72,
    "SMALL E" => 101,
    "CAPITAL R" => 82,
    "SMALL T" => 116,
    "SMALL L" => 108,
    "SMALL F" => 102,
    "SMALL G" => 103,
    "CAPITAL J" => 74,
    "CAPITAL U" => 85,
    "SMALL ZETA" => 950,
    "CAPITAL PI" => 928,
    "CAPITAL BETA" => 914,
    "CAPITAL TAU" => 932,
    "CAPITAL CHI" => 935,
    "CAPITAL EPSILON" => 917,
    "SMALL PHI" => 966,
    "SMALL XI" => 958,
    "SMALL GAMMA" => 947,
    "SMALL ALPHA" => 945,
    "CAPITAL DELTA" => 916,
    "SMALL NU" => 957,
    "CAPITAL NU" => 925,
    "SMALL CHI" => 967,
    "CAPITAL ETA" => 919,
    "CAPITAL ALPHA" => 913,
    "CAPITAL PHI" => 934,
    "CAPITAL UPSILON" => 933,
    "CAPITAL RHO" => 929,
    "CAPITAL MU" => 924,
    "CAPITAL THETA" => 920,
    "CAPITAL ZETA" => 918,
    "CAPITAL XI" => 926,
    "SMALL IOTA" => 953,
    "SMALL THETA" => 952,
    "SMALL SIGMA" => 963,
    "CAPITAL OMICRON" => 927,
    "SMALL EPSILON" => 949,
    "SMALL RHO" => 961,
    "SMALL BETA" => 946,
    "SMALL ETA" => 951,
    "CAPITAL OMEGA" => 937,
    "CAPITAL GAMMA" => 915,
    "CAPITAL IOTA" => 921,
    "SMALL TAU" => 964,
    "SMALL DELTA" => 948,
    "CAPITAL LAMDA" => 923,
    "CAPITAL PSI" => 936,
    "SMALL MU" => 956,
    "SMALL UPSILON" => 965,
    "SMALL PSI" => 968,
    "SMALL PI" => 960,
    "SMALL OMEGA" => 969,
    "CAPITAL KAPPA" => 922,
    "SMALL OMICRON" => 959,
    "SMALL LAMDA" => 955,
    "SMALL KAPPA" => 954,
    "CAPITAL SIGMA" => 931,
    "DIGIT ZERO" => ?0,
    "DIGIT ONE" => ?1,
    "DIGIT TWO" => ?2,
    "DIGIT THREE" => ?3,
    "DIGIT FOUR" => ?4,
    "DIGIT FIVE" => ?5,
    "DIGIT SIX" => ?6,
    "DIGIT SEVEN" => ?7,
    "DIGIT EIGHT" => ?8,
    "DIGIT NINE" => ?9
  }

  # TODO: find a better name for this
  def build_function_without_utf8_characters(unicode_char, category, arguments) do
    opts = Keyword.fetch!(arguments, :opts)

    hex_code = Integer.to_string(unicode_char.code, 16)
    func = String.to_atom(unicode_char.short_name)

    lookup_name = String.replace(unicode_char.name, category.unicode <> " ", "")
    maybe_different_char_code = Map.get(@alpha_greek_num_name_to_code_map, lookup_name)

    if maybe_different_char_code do
      quote do
        @doc """
        Mathematical character #{unquote(<<unicode_char.code::utf8>>)} (U+#{unquote(hex_code)})
        """
        def unquote(func)(opts \\ []) do
          default_opts = unquote(Macro.escape(opts))

          new_opts =
            Enum.reduce(default_opts, opts, fn {k, v}, old_opts ->
              Keyword.put_new(old_opts, k, v)
            end)

          Quartz.Text.Tspan.new(
            unquote(<<maybe_different_char_code::utf8>>),
            Quartz.Config.get_math_character_attributes(new_opts)
          )
        end
      end
    else
      quote do
        @doc """
        Mathematical character #{unquote(<<unicode_char.code::utf8>>)} (U+#{unquote(hex_code)})
        """
        def unquote(func)(opts \\ []) do
          Quartz.Text.Tspan.new(
            unquote(<<unicode_char.code::utf8>>),
            Quartz.Config.get_math_character_attributes(opts)
          )
        end
      end
    end
  end
end
