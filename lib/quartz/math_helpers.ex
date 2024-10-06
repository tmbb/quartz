defmodule Quartz.MathHelpers do
  @moduledoc false

  alias Quartz.Math.UnicodeMathCategory
  alias Quartz.Math.UnicodeDatabase
  alias Quartz.Math.UnicodeChar

  require Logger

  @math_categories [
    %UnicodeMathCategory{
      name: "Italic",
      unicode: "MATHEMATICAL ITALIC",
      prefix: "italic",
      groups: [:latin, :greek],
      function_builder:
        {UnicodeMathCategory, :build_function_without_utf8_characters,
         [opts: [weight: "normal", style: "italic"]]}
    },
    %UnicodeMathCategory{
      name: "Bold",
      unicode: "MATHEMATICAL BOLD",
      prefix: "bold",
      groups: [:latin, :greek, :digits],
      function_builder:
        {UnicodeMathCategory, :build_function_without_utf8_characters,
         [opts: [weight: "bold", style: "normal"]]}
    },
    %UnicodeMathCategory{
      name: "Bold Italic",
      unicode: "MATHEMATICAL BOLD ITALIC",
      prefix: "bold_italic",
      groups: [:latin, :greek],
      function_builder:
        {UnicodeMathCategory, :build_function_without_utf8_characters,
         [opts: [style: "italic", weight: "bold"]]}
    },
    %UnicodeMathCategory{
      name: "Script",
      unicode: "MATHEMATICAL SCRIPT",
      prefix: "script",
      groups: [:latin]
    },
    %UnicodeMathCategory{
      name: "Bold Script",
      unicode: "MATHEMATICAL BOLD SCRIPT",
      prefix: "bold_script",
      groups: [:latin]
    },
    %UnicodeMathCategory{
      name: "Fraktur",
      unicode: "MATHEMATICAL FRAKTUR",
      prefix: "fraktur",
      groups: [:latin]
    },
    %UnicodeMathCategory{
      name: "Double-Struck (blackboard-bold)",
      unicode: "MATHEMATICAL DOUBLE-STRUCK",
      prefix: "bb",
      groups: [:latin, :digits]
    },
    %UnicodeMathCategory{
      name: "Sans-serif",
      unicode: "MATHEMATICAL SANS-SERIF",
      prefix: "sans",
      groups: [:latin, :digits]
    },
    %UnicodeMathCategory{
      name: "Sans-serif Bold",
      unicode: "MATHEMATICAL SANS-SERIF BOLD",
      prefix: "sans_bold",
      groups: [:latin, :digits]
    },
    %UnicodeMathCategory{
      name: "Sans-serif Italic",
      unicode: "MATHEMATICAL SANS-SERIF ITALIC",
      prefix: "sans_italic",
      groups: [:latin]
    },
    %UnicodeMathCategory{
      name: "Sans-serif Italic",
      unicode: "MATHEMATICAL SANS-SERIF BOLD ITALIC",
      prefix: "sans_bold_italic",
      groups: [:latin]
    },
    %UnicodeMathCategory{
      name: "Monospaced",
      unicode: "MATHEMATICAL MONOSPACE",
      prefix: "mono",
      groups: [:latin, :digits]
    }
  ]

  @math_greek_letters [
    "ALPHA",
    "BETA",
    "GAMMA",
    "DELTA",
    "EPSILON",
    "ZETA",
    "ETA",
    "THETA",
    "IOTA",
    "KAPPA",
    "LAMDA",
    "MU",
    "NU",
    "XI",
    "OMICRON",
    "PI",
    "RHO",
    "SIGMA",
    "TAU",
    "UPSILON",
    "PHI",
    "CHI",
    "PSI",
    "OMEGA"
  ]


  alias Quartz.Math.UnicodeDatabase

  def dummy() do
    characters = ~c[ABCDEFGHIJKLMNOPQRSTUVWXYZ]
    capital_letters = for c <- characters, do: {"CAPITAL #{<<c::utf8>>}", c}
    small_letters = for c <- characters, do: {"SMALL #{<<c::utf8>>}", c + 32}
    letters = capital_letters ++ small_letters

    dbg(Enum.into(letters, %{}), limit: :infinity)

    :ok
  end


  def long_character_names_for_group(group) do
    case group do
      :latin ->
        letters = ~c[ABCDEFGHIJKLMNOPQRSTUVWXYZ]
        capital_letters = for c <- letters, do: "CAPITAL #{<<c::utf8>>}"
        small_letters = for c <- letters, do: "SMALL #{<<c::utf8>>}"
        capital_letters ++ small_letters

      :digits ->
        digits = ~w(ZERO ONE TWO THREE FOUR FIVE SIX SEVEN EIGHT NINE)
        for digit <- digits, do: "DIGIT #{digit}"

      :greek ->
        letters = @math_greek_letters

        capital_letters = for c <- letters, do: "CAPITAL #{c}"
        small_letters = for c <- letters, do: "SMALL #{c}"
        capital_letters ++ small_letters
    end
  end

  def short_character_names_for_group(group) do
    case group do
      :latin ->
        letters = ~c[ABCDEFGHIJKLMNOPQRSTUVWXYZ]
        capital_letters = for c <- letters, do: <<c::utf8>>
        small_letters = for c <- letters, do: String.downcase(<<c::utf8>>)
        capital_letters ++ small_letters

      :digits ->
        _digits = ~w(0 1 2 3 4 5 6 7 8 9)

      :greek ->
        letters = @math_greek_letters

        capital_letters =
          for c <- letters do
            c
            |> String.replace(" ", "_")
            |> String.downcase()
            |> String.capitalize()
          end

        small_letters =
          for c <- letters do
            c
            |> String.replace(" ", "_")
            |> String.downcase()
          end

        capital_letters ++ small_letters
    end
  end

  defp build_short_char_name(prefix, char) do
    case prefix do
      "" -> char
      _other -> "#{prefix}_#{char}"
    end
  end

  defp build_long_char_name(cat, char) do
    "#{cat} #{char}"
  end

  def characters_for_category(database, %UnicodeMathCategory{} = category) do
    long_names =
      for group <- category.groups do
        chars = long_character_names_for_group(group)

        for char <- chars do
          build_long_char_name(category.unicode, char)
        end
      end
      |> List.flatten()

    short_names =
      for group <- category.groups do
        chars = short_character_names_for_group(group)

        for char <- chars do
          build_short_char_name(category.prefix, char)
        end
      end
      |> List.flatten()

    codes =
      Enum.map(long_names, fn name ->
        UnicodeDatabase.fetch_code_from_name!(database, name)
      end)

    for {name, short_name, code} <- Enum.zip([long_names, short_names, codes]) do
      last_component = name |> String.split(" ") |> Enum.at(-1)

      ascii_equivalent =
        case last_component do
          <<c::8>> when c < 256 -> c
          _other -> nil
        end

      %UnicodeChar{
        name: name,
        short_name: short_name,
        ascii_equivalent: ascii_equivalent,
        code: code
      }
    end
  end

  defmacro build_function_clauses() do
    db = UnicodeDatabase.build()

    categories_ast =
      for category <- @math_categories do
        chars = characters_for_category(db, category)

        function_names = for char <- chars, do: String.to_atom(char.short_name)

        function_definitions =
          for char <- chars do
            {m, f, a} = category.function_builder
            apply(m, f, [char, category, a])
          end

        cat_function_name =
          category.unicode
          |> String.downcase()
          |> String.replace(" ", "_")
          |> String.replace("-", "_")
          |> Kernel.<>("_sketches")
          |> String.to_atom()

        quote do
          unquote_splicing(function_definitions)

          @spec unquote(cat_function_name)(Keyword.t()) ::
                  {Quartz.MathHelpers.UnicodeCatergory.t(), Quartz.Sketch.t()}
          def unquote(cat_function_name)(opts \\ []) do
            functions = unquote(function_names)

            sketches =
              for func <- functions do
                {func, apply(__MODULE__, func, [opts])}
              end

            {unquote(Macro.escape(category)), sketches}
          end
        end
      end

    quote do
      (unquote_splicing(categories_ast))
    end
  end
end
