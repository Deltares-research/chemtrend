<template>
  <v-sheet
    :class="drawer ? 'nav-open' : ''"
    height="100%"
    >
    <v-card height="100%">
      <v-toolbar>
      <v-toolbar-title text="Trendresultaten">
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-btn @click="$emit('update:bottomPanel', false)" flat icon="mdi-close"></v-btn>
      </v-toolbar>
      <v-card-text class="bottom-panel ma-0 pa-0">
        <router-view></router-view>
      </v-card-text>
    </v-card>
  </v-sheet>
</template>

<script>
export default {
  props: {
    drawer: {
      type: Boolean
    },
    bottomPanel: {
      type: Boolean
    }
  }
}
</script>

<style scoped>
.nav-open {
  padding-left: 360px;
}

.bottom-panel {
  overflow-y: auto;
}
</style>
