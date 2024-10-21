<template>
  <div>
    <v-expansion-panels
      width="100%"
      v-model="panels"
      multiple
    >
      <v-expansion-panel
        v-for="trend in trends" :key="trend.trendData.title"
      >
        <v-expansion-panel-title>{{ trend.trendData.title }}</v-expansion-panel-title>
        <v-expansion-panel-text>
          <location-trend :trend="trend" />
        </v-expansion-panel-text>
      </v-expansion-panel>
    </v-expansion-panels>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import LocationTrend from '@/components/graphs/LocationTrend.vue'

export default {
  props: {
    drawer: {
      type: Boolean
    }
  },
  data () {
    return {
      panels: [0]
    }
  },
  computed: {
    ...mapGetters(['trends'])
  },
  components: {
    LocationTrend
  },
  watch: {
    trends () {
      this.panels = [0]
    }
  }
}
</script>
