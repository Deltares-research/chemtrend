<template>
  <v-dialog max-width="70%">
    <template v-slot:activator="{ props: dialog }">
    <v-tooltip text="Informatie over de trendgrafieken" location="top">
        <template v-slot:activator="{ props: tooltip }">
          <v-btn icon="mdi-information-outline" v-bind="mergeProps(dialog, tooltip)"></v-btn>
        </template>
    </v-tooltip>
    </template>
    <template v-slot:default="{ isActive }">
    <v-card>
        <v-card-title class="text-h4">Informatie over de trendgrafieken</v-card-title>
        <v-card-text>
          <v-row class="mb-2">
            <v-img
              src="../../assets/graph_explaination.png"
            ></v-img>
          </v-row>
          <v-row v-for="(step, index) in infoSteps" :key="index" no-gutters class="mb-5">
            <v-col no-gutters cols="auto">
              <v-icon
                class="ma-2 bg-black rounded-circle"
                color="yellow-darken-1"
                :icon="'mdi-numeric-' + index + '-circle'"
              ></v-icon>
            </v-col>
            <v-col class="text-h6 ml-1 align-self-center">{{ step.title }}</v-col>
            <v-col cols="12">{{ step.description }}</v-col>
          </v-row>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn text="Sluiten" @click="isActive.value = false"></v-btn>
        </v-card-actions>
    </v-card>
    </template>
  </v-dialog>
</template>

<script>
import { mergeProps } from 'vue'

export default {
  data () {
    return {
      infoSteps: {
        1: {
          title: 'Legenda meetlocatie grafiek',
          description: 'lorel ipsum dolor sit amet, consectetur adipiscing elit.'
        },
        2: {
          title: 'Titel meetlocatie',
          description: 'lorel ipsum dolor sit amet, consectetur adipiscing elit.'
        },
        3: {
          title: 'Functieknoppen grafiek',
          description: 'lorel ipsum dolor sit amet, consectetur adipiscing elit.'
        },
        4: {
          title: 'Legenda regio grafiek',
          description: 'lorel ipsum dolor sit amet, consectetur adipiscing elit.'
        },
        5: {
          title: 'Titel regio',
          description: 'lorel ipsum dolor sit amet, consectetur adipiscing elit.'
        },
        6: {
          title: 'Functieknoppen trendresultaten',
          description: 'lorel ipsum dolor sit amet, consectetur adipiscing elit.'
        },
        7: {
          title: 'Andere trendresultaten',
          description: 'lorel ipsum dolor sit amet, consectetur adipiscing elit.'
        }
      }
    }
  },
  methods: {
    mergeProps
  }
}
</script>
