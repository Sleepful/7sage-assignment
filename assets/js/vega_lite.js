import vegaEmbed from "vega-embed";
export const VegaLite = {
  mounted() {
    console.log("Vega Lite hoo")
    this.spec = JSON.parse(this.el.getAttribute("data-spec"))
    console.log("Vega Lite spec:", this.spec)
    vegaEmbed(this.el, this.spec)
      .then((result) => result.view)
      .catch((error) => console.error(error));
  },
};
