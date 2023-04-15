defmodule M.Data do
  use GenServer
  require Explorer.DataFrame, as: DF
  
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

  def school_names() do
    GenServer.call(__MODULE__, {:school_names})
  end
  
  defp school_sentence(school_name, school_frame) do
    # 1. Output a sentence about the data. For example, if a user focuses
    # on or selects Harvard, you might print, “The median LSAT score for Harvard in 2022 
    # was 174.” You don’t have to use this sentence, though. You can focus on any dimension
    # of the data, and you can choose where and under what conditions to output the sentence.
    mean = school_frame["L50"] |> Explorer.Series.mean() |> Float.round(2)
    years = school_frame["First Year Class"] |> Explorer.Series.sort() 
    first_year = years |> Explorer.Series.first()
    last_year = years |> Explorer.Series.last()
    school_name = school_frame["School"] |> Explorer.Series.head(1) |> Explorer.Series.to_list() |> hd()
    sentence = "The average median score for “#{school_name}” across years #{first_year} and #{last_year} is: #{mean}"
    sentence
  end

  defp medians_rows(_school_name, school_frame) do
    school_frame 
      |> DF.select(["L25", "L50", "L75", "First Year Class"]) 
      |> DF.to_rows()
  end
  ## Callbacks

  @impl true
  def init(_params) do
    
    dir = Application.app_dir(:medians, [ "priv", "static"])
    data_file = Path.join([dir, "data.csv"])
    {:ok, data_frame } = DF.from_csv(data_file, delimiter: "\t")
    to_int = fn str -> 
      if str == "Unranked" || str == nil do
        # nils will get dropped later
        999
      else
        [ number | _rest] = String.split(str, "-")
        String.to_integer(number)
      end
    end
    rank_sort = data_frame["Rank"] |> Explorer.Series.transform(&to_int.(&1))
    data_frame = data_frame 
      |> DF.put(:rank_sort, rank_sort)
      |> DF.drop_nil(["Rank", "School", "First Year Class"])
      |> DF.mutate(school_with_rank: col("Rank") <> " - " <> col("School") )
      |> DF.arrange(rank_sort)
    {:ok, %{ data: data_frame }}
  end

  @impl true
  def handle_call({:school_names}, _from, state) do
    %{data: frame} = state
    names = frame["school_with_rank"] 
      |> Explorer.Series.distinct()
      |> Explorer.Series.to_list()
    reply = {:ok, names}
    {:reply, reply, state}
  end
  @impl true
  def handle_call({:school_analytics, school_name}, _from, state) do
    %{data: frame} = state
    school_frame = DF.filter(frame, col("school_with_rank") == ^school_name)
    if DF.n_rows( school_frame ) == 0 do
      {:reply, {:error, "School name not found"}, state}
    else
      sentence = school_sentence(school_name, school_frame)
      rows = medians_rows(school_name, school_frame)
      reply = {:ok, %{sentence: sentence, medians_rows: rows}}
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
