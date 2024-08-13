<template>
  <v-app-bar :elevation="2">
    <template v-slot:prepend>
        <v-app-bar-nav-icon  @click="$emit('toggle-drawer')"></v-app-bar-nav-icon>
    </template>

    <v-app-bar-title>Application Bar</v-app-bar-title>
  </v-app-bar>
</template>
