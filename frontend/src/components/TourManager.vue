<template>
  <v-tour name="globalTour" :steps="steps"></v-tour>
</template>

<script>
export default {
  data () {
    return {
      steps: []
    }
  },
  methods: {
    addStep (step) {
      this.steps.push(step)
    },
    startTour () {
      if (this.steps.length === 0) {
        console.error('No steps defined for the tour.')
        return
      }
      this.$tours.globalTour.start()
    },
    stopTour () {
      this.$tours.globalTour.stop()
    }
  }
}
</script>
