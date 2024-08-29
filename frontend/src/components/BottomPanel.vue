<template>
  <v-card :class="{'collapsed': panelIsCollapsed, 'expanded': !panelIsCollapsed}">
    <v-card-actions class="justify-end">
      <v-btn @click="toggleCollapse" icon>
        <v-icon>mdi-chevron-down</v-icon>
      </v-btn>
    </v-card-actions>
    <v-card-text v-if="!panelIsCollapsed">
      <router-view></router-view>
    </v-card-text>
  </v-card>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'

export default {
  computed: {
    ...mapGetters(['panelIsCollapsed'])
  },
  methods: {
    ...mapActions(['togglePanelCollapse']),
    toggleCollapse () {
      this.togglePanelCollapse()
    }
  }
}
</script>

<style scoped>
.collapsed {
  max-height: 0px;
  overflow: hidden;
}

.expanded {
  min-height: 600px;
  transition: max-height 0.3s ease;
}

v-card {
  transition: max-height 0.3s ease;
}

.v-card-actions {
  display: flex;
  justify-content: flex-end;
}
</style>
