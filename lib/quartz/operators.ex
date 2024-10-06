defmodule Quartz.Operators do
  @moduledoc """
  Imports versions of the arithmetic operators (`+`, `-`, `*` and `/`)
  that work on polynomials (`#Polynomial<...>`, used for lengths in Quartz)
  and hides the operators from the `Kernel` module which only work on numbers.
  These arithmetic operators work on both polynomials and numbers and
  will convert the result to a number if the result is a constant.

  This module is meant to be used as `use Quartz.Operators`
  """

  defmacro __using__(_opts \\ []) do
    quote do
      use Dantzig.Polynomial.Operators
    end
  end

  @doc """
  Replaces the arithmetic operators (`+`, `-`, `*` and `/`)
  in the given code by the corresponding polynomial operators.
  """
  defmacro algebra(ast) do
    Dantzig.Polynomial.replace_operators(ast)
  end
end
