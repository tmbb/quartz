defmodule Quartz.MathHelpers do
  @moduledoc false

  alias Quartz.Math.UnicodeMathCategory
  alias Quartz.Math.UnicodeDatabase
  alias Quartz.Math.UnicodeChar

  require Logger

  for path <- File.ls!("assets/math_characters_chart") do
    @external_resource path
  end

  @math_categories [
    %UnicodeMathCategory{
      name: "Italic",
      slug: "italic",
      unicode: "MATHEMATICAL ITALIC",
      prefix: "italic",
      groups: [:latin, :greek],
      function_builder:
        {UnicodeMathCategory, :build_function_without_utf8_characters,
         [opts: [weight: "normal", style: "italic"]]}
    },
    %UnicodeMathCategory{
      name: "Bold",
      slug: "bold",
      unicode: "MATHEMATICAL BOLD",
      prefix: "bold",
      groups: [:latin, :greek, :digits],
      function_builder:
        {UnicodeMathCategory, :build_function_without_utf8_characters,
         [opts: [weight: "bold", style: "normal"]]}
    },
    %UnicodeMathCategory{
      name: "Bold Italic",
      slug: "bold_italic",
      unicode: "MATHEMATICAL BOLD ITALIC",
      prefix: "bold_italic",
      groups: [:latin, :greek],
      function_builder:
        {UnicodeMathCategory, :build_function_without_utf8_characters,
         [opts: [style: "italic", weight: "bold"]]}
    },
    %UnicodeMathCategory{
      name: "Script",
      slug: "script",
      unicode: "MATHEMATICAL SCRIPT",
      prefix: "script",
      groups: [:latin]
    },
    %UnicodeMathCategory{
      name: "Bold Script",
      slug: "bold_script",
      unicode: "MATHEMATICAL BOLD SCRIPT",
      prefix: "bold_script",
      groups: [:latin]
    },
    %UnicodeMathCategory{
      name: "Fraktur",
      slug: "fraktur",
      unicode: "MATHEMATICAL FRAKTUR",
      prefix: "fraktur",
      groups: [:latin]
    },
    %UnicodeMathCategory{
      name: "Double-Struck (blackboard-bold)",
      slug: "double_struck",
      unicode: "MATHEMATICAL DOUBLE-STRUCK",
      prefix: "bb",
      groups: [:latin, :digits]
    },
    %UnicodeMathCategory{
      name: "Sans-serif",
      slug: "sans_serif",
      unicode: "MATHEMATICAL SANS-SERIF",
      prefix: "sans",
      groups: [:latin, :digits]
    },
    %UnicodeMathCategory{
      name: "Sans-serif Bold",
      slug: "sans_serif_bold",
      unicode: "MATHEMATICAL SANS-SERIF BOLD",
      prefix: "sans_bold",
      groups: [:latin, :digits]
    },
    %UnicodeMathCategory{
      name: "Sans-serif Italic",
      slug: "sans_serif_italic",
      unicode: "MATHEMATICAL SANS-SERIF ITALIC",
      prefix: "sans_italic",
      groups: [:latin]
    },
    %UnicodeMathCategory{
      name: "Sans-serif Bold Italic",
      slug: "sans_serif_bold_italic",
      unicode: "MATHEMATICAL SANS-SERIF BOLD ITALIC",
      prefix: "sans_bold_italic",
      groups: [:latin]
    },
    %UnicodeMathCategory{
      name: "Monospaced",
      slug: "monospaced",
      unicode: "MATHEMATICAL MONOSPACE",
      prefix: "mono",
      groups: [:latin, :digits]
    }
  ]

  math_greek_letters = [
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

  @math_greek_letters math_greek_letters

  non_symbol_bb =
    for letter <- ~c'ABCDEFGHIJKLMNOPQRSTUVWXYZ' do
      :"symbol_#{<<letter::8, letter::8>>}"
    end

  non_symbol_html_entities = [
    :symbol_grave,
    :symbol_gt,
    :symbol_lt,
    :symbol_amp
  ]

  @exclude_from_symbols non_symbol_html_entities ++
                          non_symbol_bb

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
      %UnicodeChar{
        name: name,
        short_name: short_name,
        code: code
      }
    end
  end

  defmacro build_sym_category() do
    {:ok, doc} =
      "priv/typst-symbols.html"
      |> File.read!()
      |> Floki.parse_document()

    names_and_codes =
      for _li = {_tag, attrs, _content} <- Floki.find(doc, ~s'li[data-codepoint]') do
        id = :proplists.get_value("id", attrs)
        # The code is in base 10 here
        code = :proplists.get_value("data-codepoint", attrs)
        {i_code, ""} = Integer.parse(code, 10)

        func =
          id
          |> String.replace(".", "_")
          |> String.replace("-", "_")
          |> String.to_atom()

        {func, i_code}
      end

    filtered_funcs_and_codes =
      Enum.reject(names_and_codes, fn {func, _code} ->
        func in @exclude_from_symbols or
          String.ends_with?(to_string(func), "_t") or
          String.ends_with?(to_string(func), "_b")
      end)

    named_definitions =
      for {func, i_code} <- filtered_funcs_and_codes do
        hex_code = Integer.to_string(i_code, 16)

        function_definition =
          quote do
            @doc """
            Symbol #{unquote(<<i_code::utf8>>)} (U+#{unquote(hex_code)})
            """
            def unquote(func)(opts \\ []) do
              Quartz.Text.Tspan.new(
                unquote(<<i_code::utf8>>),
                Quartz.Config.get_math_character_attributes(opts)
              )
            end
          end

        {func, function_definition}
      end

    {function_names, function_definitions} = Enum.unzip(named_definitions)

    cat_function_name = :mathematical_symbol_sketches
    human_category_name = "Mathematical Symbols"

    quote do
      unquote_splicing(function_definitions)

      @doc """
      Math characters belonging to the *#{unquote(human_category_name)}* category.

      ![Characters chart for this category](assets/math_characters_chart/symbols.png)
      """
      @spec unquote(cat_function_name)(Keyword.t()) ::
              {Quartz.Math.UnicodeCatergory.t(), list(Quartz.Sketch.t())}
      def unquote(cat_function_name)(opts \\ []) do
        functions = unquote(function_names)

        sketches =
          for func <- functions do
            {func, apply(__MODULE__, func, [opts])}
          end

        category = %UnicodeMathCategory{
          name: "Symbols",
          slug: "symbols",
          unicode: "MATHEMATICAL SYMBOLS",
          prefix: "symbol",
          groups: []
        }

        {category, sketches}
      end
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

        human_category_name =
          category.unicode
          |> String.downcase()
          |> String.capitalize()

        quote do
          unquote_splicing(function_definitions)

          @doc """
          Math characters belonging to the *#{unquote(human_category_name)}* category.

          ![Characters chart for this category](assets/math_characters_chart/#{unquote(category.slug)}.png)
          """
          @spec unquote(cat_function_name)(Keyword.t()) ::
                  {Quartz.Math.UnicodeCatergory.t(), list(Quartz.Sketch.t())}
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
