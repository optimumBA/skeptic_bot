let PageWidthHooks = {}

PageWidthHooks.PageWidth = {
  mounted() {
    width = this.getWidth()
    console.log(`Width is ${width}`)

    this.pushEvent('assign-batch-size', { page_width: width })
  },

  updated() {},

  destroyed() {},

  getWidth() {
    return Math.max(
      document.body.scrollWidth,
      document.documentElement.scrollWidth,
      document.body.offsetWidth,
      document.documentElement.offsetWidth,
      document.documentElement.clientWidth
    )
  },
}

export default PageWidthHooks
