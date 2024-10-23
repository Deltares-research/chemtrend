<template>
  <v-sheet
    v-model="collapsed"
    :class="drawer ? 'nav-open' : ''"
    height="100%"
    >
    <v-card>
      <v-toolbar>
      <v-toolbar-title text="Trendresultaten">
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-btn @click="$emit('update:bottomPanel', false)" flat icon="mdi-close"></v-btn>
    </v-toolbar>
      <v-card-text>
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
  overflow-y: auto;
}
</style>
