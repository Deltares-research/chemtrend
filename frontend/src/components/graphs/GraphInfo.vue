<template>
  <div>
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
          <v-card-title class="text-h4" >Informatie over de trendgrafieken</v-card-title>
          <v-card-text>
              <v-row class="pb-10 pt-5" justify="center">
                <v-img
                  src="../../assets/graph_explaination.png"
                  aspect-ratio="16/9"
                  max-width="85%"
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
              <v-col cols="12">
                <p v-for="(line, lineNumber) in step.description.split('\n')" :key="lineNumber">{{ line }}</p>
              </v-col>
            </v-row>
          </v-card-text>
          <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn text="Sluiten" @click="isActive.value = false"></v-btn>
          </v-card-actions>
      </v-card>
      </template>
    </v-dialog>
  </div>
</template>

<script>
import { mergeProps } from 'vue'

export default {
  watch: {
    mapComponentDimensions: {
      handler (newValue) {
        console.log(newValue)
      }
    },
    deep: true,
    eager: true
  },
  data () {
    return {
      infoSteps: {
        1: {
          title: 'Legenda meetlocatie grafiek',
          description: 'Meetreeks, onderscheid tussen normale meting (gesloten cirkel) of < rapportagegrens (open cirkel).\n' +
            'Trendlijnen voor gekozen trendperiode: Lowess methode (doorgetrokken lijn) en Theil Sen methode (gestippelde lijn).\n' +
            'Lijnen zijn aan/uit te zetten door er op te klikken.\n' +
            'Waarde zichtbaar door over een meetpunt te bewegen.'
        },
        2: {
          title: 'Titel meetlocatie',
          description: 'Titel bevat het stof en de locatiecode.\n' +
            'Trendresultaat: significantie volgens de Seasonal Mann Kendall trendtest\n' +
            'Trendhelling: helling over 10 jaar volgens de Theil-Sen hellingschatter'
        },
        3: {
          title: 'Functieknoppen grafiek',
          description: 'Zoom: Zoom in op te tonen periode (tijd-as)\n' +
            'Zoom reset: Ga terug naar vorige zoomniveau\n' +
            'Restore: Zoom uit naar volledige reeks\n' +
            'Save as image: Sla de grafiek op (png-bestand)\n' +
            'Data view: Bekijk de meetwaardentabel'
        },
        4: {
          title: 'Legenda regio grafiek',
          description: 'Trend van andere locaties binnen regio\n' +
            'Kleur afgestemd op trendrichting: Stijgend: roodbruin; Dalend: lichtblauw; Niet significant: grijs\n' +
            'Trend van geselecteerde locatie (pers)\n' +
            '25-, 50-, en 75-percentielen van trendlijnen binnen de geselecteerde regio'
        },
        5: {
          title: 'Titel regio',
          description: 'Titel bevat het stof en Regionaam.\n' +
            'Kleur titel komt overeen met geselecteerde regio'
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
