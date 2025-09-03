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
            <v-row>
              <v-col cols="12" v-for="(warning, i)  in activeWarnings" :key="i">
                <p class="font-weight-bold text-info">{{ warning }}</p>
              </v-col>
            </v-row>
            <v-row class="pb-10 pt-0" justify="center">
              <v-img
                src="../../assets/graph_explanation_2.png"
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
                <v-row v-for="(item, itemIndex) in step.description" :key="itemIndex" no-gutters>
                  <v-col class="image-width" v-if="loadashGet(item, 'imageName')">
                    <v-img
                      :src="`./infoSteps/${item.imageName}.png`"
                    ></v-img>
                  </v-col>
                  <v-col class="align-self-center">
                    <v-icon v-for="(icon, iconIndex) in loadashGet(item, 'iconName', [])" :key="iconIndex" class="mb-2 mt-1">{{ icon }}</v-icon>
                    {{ item.text }}
                  </v-col>
                </v-row>
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
import { mapGetters } from 'vuex'
import { mergeProps } from 'vue'
import _ from 'lodash'

const locationWarning = 'Let op: Er is geen locatie geselecteerd op de kaart, dus er worden geen grafieken weergegeven. Selecteer een stof aan de linkerkant van het scherm en klik op een locatie op de kaart om de bijbehorende grafieken te zien.'
const regionWarning = 'Let op: als er geen regio is geselecteerd, zet u de schakelaars voor een regio aan de linkerkant van het scherm aan. Meerdere regio\'s kunnen worden geselecteerd.'

export default {
  computed: {
    ...mapGetters(['trends']),
    activeWarnings () {
      const activeWarnings = []
      if (_.isNil(this.trends) || this.trends.length === 0) {
        activeWarnings.push(locationWarning)
      }
      if (_.isNil(this.$route.query.region) || this.$route.query.region === '') {
        activeWarnings.push(regionWarning)
      }
      return activeWarnings
    }
  },
  data () {
    return {
      warnings: [],
      infoSteps: {
        1: {
          title: 'Legenda meetlocatie grafiek',
          description: [
            {
              text: 'Meetreeks, onderscheid tussen normale meting (gesloten cirkel) of < rapportagegrens (open cirkel).',
              imageName: 'location_circles'
            },
            {
              text: 'Trendlijnen voor gekozen trendperiode: Lowess methode (doorgetrokken lijn) en Theil Sen methode (gestippelde lijn). Als er onvoldoende metingen zijn om een trend te berekenen (de locatiepunten zijn grijze cirkels op de kaart), dan zijn die twee lijnen niet beschikbaar.',
              imageName: 'trendlines'
            },
            { text: 'Lijnen zijn aan/uit te zetten door er op te klikken.' },
            { text: 'Waarde zichtbaar door over een meetpunt te bewegen.' }
          ]
        },
        2: {
          title: 'Titel meetlocatie',
          description: [
            { text: 'Titel bevat het stof en de locatiecode.' },
            { text: 'Trendresultaat: significantie volgens de Seasonal Mann Kendall trendtest.' },
            { text: 'Trendhelling: helling over 10 jaar volgens de Theil-Sen hellingschatter.' }
          ]
        },
        3: {
          title: 'Functieknoppen grafiek',
          description: [
            {
              text: 'Zoom in op te tonen periode (tijd-as).',
              imageName: 'zoom'
            },
            {
              text: 'Ga terug naar vorige zoomniveau.',
              imageName: 'zoom_reset'
            },
            {
              text: 'Zoom uit naar volledige reeks.',
              imageName: 'restore'
            },
            {
              text: 'Sla de grafiek op (png-bestand).',
              imageName: 'save_as'
            },
            {
              text: 'Bekijk de meetwaardentabel.',
              imageName: 'data_view'
            }
          ]
        },
        4: {
          title: 'Legenda regio grafiek',
          description: [
            { text: 'Trend van andere locaties binnen regio.' },
            {
              text: 'Kleur afgestemd op trendrichting: Stijgend: roodbruin; Dalend: lichtblauw; Niet significant: lichtgeel.',
              imageName: 'trends'
            },
            {
              text: 'Trend van geselecteerde locatie (paars).',
              imageName: 'location_trend'
            },
            {
              text: '25-, 50-, en 75-percentielen van trendlijnen binnen de geselecteerde regio.',
              imageName: 'percentile_trends'
            }
          ]
        },
        5: {
          title: 'Titel regio',
          description: [
            {
              text: 'Titel bevat het stof en Regionaam. Kleur titel komt overeen met geselecteerde regio.',
              imageName: 'regional_color'
            }
          ]
        },
        6: {
          title: 'Functieknoppen trendresultaten',
          description: [
            {
              text: 'Verwijder alle trendgrafieken (max. is 10 zoekresultaten).',
              iconName: ['mdi-delete-outline']
            },
            {
              text: 'Verberg/toon kaart en vergroot/verklein het grafieken paneel.',
              iconName: ['mdi-earth', 'mdi-earth-off']
            },
            {
              text: 'Paneel uit-/samenvouwen om grafieken te verbergen/tonen.',
              iconName: ['mdi-arrow-expand-up', 'mdi-arrow-expand-down']
            }
          ]
        },
        7: {
          title: 'Andere trendresultaten',
          description: [
            {
              text: 'Verwijder trendgrafiek.',
              iconName: ['mdi-delete']
            },
            {
              text: 'Trendgrafiek uit-/samenvouwen.',
              iconName: ['mdi-chevron-up', 'mdi-chevron-down']
            }
          ]
        }
      }
    }
  },
  methods: {
    mergeProps,
    loadashGet (obj, path, defaultValue = null) {
      return _.get(obj, path, defaultValue)
    }
  }
}
</script>
<style scoped>
  .image-width {
    max-width: 125px;;
  }
</style>
