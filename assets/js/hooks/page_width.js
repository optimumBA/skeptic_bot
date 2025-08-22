let PageWidthHooks = {}

PageWidthHooks.PageWidth = {
  mounted() {
    width = this.getWidth()

    this.pushEvent('assign_batch_size', { page_width: width })
  },

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
