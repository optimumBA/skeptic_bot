let TypewriterHooks = {}

TypewriterHooks.Typewriter = {
  mounted() {
    const text = this.el.dataset.text
    let i = 0

    const type = () => {
      if (i < text.length) {
        this.el.innerHTML += text.charAt(i)
        i++
        setTimeout(type, 25)
      }
    }

    type()
  },
}

export default TypewriterHooks
