defmodule MWeb.PageController do
  use MWeb, :controller
  alias M.Data

  @defaults [sentence: nil, rows: nil]
  def home(conn, _params) do
    { :ok, names } = Data.school_names()
    assigns = [ form: %{}, names: names, selected: hd(names) ]
    render(conn, :home, assigns ++ @defaults )
  end

  def query(conn, %{ "name" => school_name }) do
    { :ok, %{sentence: sentence, medians_rows: rows} } = Data.school_analytics(school_name)
    { :ok, names } = Data.school_names()
    render(conn, :home, sentence: sentence, form: %{}, names: names, selected: school_name, rows: rows)
  end
  
end
