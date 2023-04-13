defmodule M.Data do
  use GenServer
  require Explorer.DataFrame, as: DF
  
  @root_dir File.cwd!()
  @data_file Path.join([ @root_dir, "priv", "static", "data.csv" ])

  def start_link(_arg) do
    params = []
    GenServer.start_link(__MODULE__, params, name: __MODULE__)
  end

  # for testing purposes:
  def frame() do
    GenServer.call(__MODULE__, :frame)
  end

  def school_analytics(school_name) do
    GenServer.call(__MODULE__, {:school_analytics, school_name})
  end

  defp school_sentence(school_name, school_frame) do
    # 1. Output a sentence about the data. For example, if a user focuses
    # on or selects Harvard, you might print, “The median LSAT score for Harvard in 2022 
    # was 174.” You don’t have to use this sentence, though. You can focus on any dimension
    # of the data, and you can choose where and under what conditions to output the sentence.
    mean = school_frame["L50"] |> Explorer.Series.mean()
    years = school_frame["First Year Class"] |> Explorer.Series.sort() 
    first_year = years |> Explorer.Series.first()
    last_year = years |> Explorer.Series.last()
    sentence = "The average median score for #{school_name} across years #{first_year} and #{last_year} is #{mean}."
    sentence
  end
  ## Callbacks

  @impl true
  def init(_params) do
    {:ok, data_frame } = DF.from_csv(@data_file)
    {:ok, %{ data: data_frame }}
  end

  @impl true
  def handle_call({:school_analytics, school_name}, _from, state) do
    %{data: frame} = state
    school_frame = DF.filter(frame, col("School") == ^school_name)
    if DF.n_rows( school_frame ) == 0 do
      {:reply, {:error, "School name not found"}, state}
    else
      sentence = school_sentence(school_name, school_frame)
      reply = {:ok, %{sentence: sentence}}
      {:reply, reply, state}
    end
  end

  # for testing purposes:
  @impl true
  def handle_call(:frame, _from, state) do
    %{data: frame} = state
    {:reply, frame, state}
  end
end
