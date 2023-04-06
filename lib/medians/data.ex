defmodule M.Data do
  use GenServer

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, 1, name: __MODULE__)
  end

  def get_data(_arg) do
    # return data for a school in a struct nicely useful to the frontend
    school_sentence("some_school_id") # the sentence could be web but lets not make it web
  end

  defp school_sentence(_arg) do
    # 1. Output a sentence about the data. For example, if a user focuses
    # on or selects Harvard, you might print, “The median LSAT score for Harvard in 2022 
    # was 174.” You don’t have to use this sentence, though. You can focus on any dimension
    # of the data, and you can choose where and under what conditions to output the sentence.
    
  end
  ## Callbacks

  @impl true
  def init(counter) do
    IO.inspect("starting process #{counter}")
    # Explorer here
    # read file from priv/static/data.csv
    # put it into a data frame
    {:ok, counter}
  end

  @impl true
  def handle_call(:get, _from, counter) do
    # Example, remove later
    {:reply, counter, counter}
  end

  @impl true
  def handle_call({:bump, value}, _from, counter) do
    # Example, remove later
    {:reply, counter, counter + value}
  end
end
