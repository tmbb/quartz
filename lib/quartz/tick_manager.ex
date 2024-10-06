defmodule Quartz.TickManager do
  @moduledoc """
  Tick managers handle the placement of ticks in the plot

  TODO: iron out the distinctions between major and minor tick managers.
  """

  alias Quartz.TickManagers.{
    AutoTickManager,
    MonthsTickManager,
    MultiplesTickManager,
    PowerMajorTickManager,
    SymbolicMultiplesTickManager
  }

  @type tick_manager :: {module(), Keyword.t()}

  @doc """
  Document this.
  """
  @spec auto_tick_manager(Keyword.t()) :: tick_manager()
  def auto_tick_manager(opts) do
    AutoTickManager.init(opts)
  end

  @doc """
  Document this.
  """
  @spec months_tick_manager(Keyword.t()) :: tick_manager()
  def months_tick_manager(opts) do
    MonthsTickManager.init(opts)
  end

  @doc """
  Document this.
  """
  @spec multiples_tick_manager(Keyword.t()) :: tick_manager()
  def multiples_tick_manager(opts) do
    MultiplesTickManager.init(opts)
  end

  @doc """
  Document this.
  """
  @spec power_tick_manager(Keyword.t()) :: tick_manager()
  def power_tick_manager(opts) do
    PowerMajorTickManager.init(opts)
  end

  @doc """
  Document this.
  """
  @spec symbolic_multiples_tick_manager(Keyword.t()) :: tick_manager()
  def symbolic_multiples_tick_manager(opts) do
    SymbolicMultiplesTickManager.init(opts)
  end
end
