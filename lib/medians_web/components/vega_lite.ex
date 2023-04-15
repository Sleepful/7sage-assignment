# adapted from: https://github.com/filipecabaco/vegalite_demo
defmodule MWeb.VegaLite do
  use Phoenix.Component
  
  def sample_vegalite(assigns) do
    rows = assigns[:median_rows]
    vg_rows = rows_to_vegalite(rows)
    spec =
      VegaLite.new(title: "LSAT results across time", width: :container, height: :container, padding: 5)
      |> VegaLite.data_from_values(vg_rows)
      |> VegaLite.mark(:line, yOffset: 120)
      |> VegaLite.encode_field(:x, "year", type: :nominal)
      # Y range min: 120
      # Y range max: 180
      |> VegaLite.encode_field(:y, "value", type: :quantitative, scale: [domain: [120, 180]])
      |> VegaLite.encode_field(:color, "name", type: :nominal, sort: "descending", title: "LSAT results")
      |> VegaLite.to_spec()

    json_spec = Jason.encode!(spec)
    assigns = Map.put(assigns, :spec, json_spec)

    render(assigns)
  end

  defp rows_to_vegalite(rows) do
    Enum.flat_map(rows, fn %{"First Year Class" => year, "L25" => l_25, "L50" => l_50, "L75" => l_75} ->
      [
        %{year: year, name: "25th percentile", value: l_25},
        %{year: year, name: "50th percentile", value: l_50},
        %{year: year, name: "75th percentile", value: l_75}
      ]
    end)
  end
  
  def render(assigns) do
    ~H"""
    <div style="width:80%; height: 500px" id="graph" phx-hook="VegaLite" phx-update="ignore" data-spec={@spec}/>
    """
  end

end
