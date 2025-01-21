<template>
  <div class="content-wrapper">
    <v-col>
      <v-row>
        <h2>Welkom bij CHEMtrend</h2>
        <p>
          CHEMtrend is een applicatie waarin op basis van meetgegevens langjarige trends in de kwaliteit van Nederlandse oppervlaktewateren worden getoond. Hiermee kan voor een uitgebreide lijst van chemische stoffen een landelijk beeld verkregen worden en de ontwikkeling van de waterkwaliteit inzichtelijk gemaakt worden zowel in de Rijkswateren als in de regionale watersystemen.
        </p>

        <p class="mt-4">
          Voor vragen kunt u contact met ons opnemen via <a href="mailto:chemtrend@deltares.nl">chemtrend@deltares.nl</a>.
        </p>

        <v-row justify="center">
          <v-btn color="primary" class="ma-6" @click="dialog = true">Meer informatie</v-btn>
        </v-row>

        <v-dialog v-model="dialog" max-width="800px">
          <v-card>
            <v-card-title class="text-h5">CHEMtrend Informatie</v-card-title>
            <v-card-text class="ma-4">
              <h2>Welkom bij CHEMtrend</h2>
              <p>
                CHEMtrend is een website waarin, met het oog op de taakuitvoering van waterbeheerders, waterschappen en provincies, op één plek de beschikbare publieke meetdata betreffende de aanwezigheid van vele chemische stoffen in het oppervlaktewater in Nederland worden getoond alsmede de ontwikkeling van de aanwezigheid van deze stoffen in de tijd in de vorm van trendgrafieken. Hiermee wordt een landelijk beeld weergegeven en wordt de ontwikkeling van de waterkwaliteit inzichtelijk gemaakt zowel in de Rijkswateren als in de regionale watersystemen.
              </p>
              <h3 class="mt-4 font-italic">Herkomst data</h3>
              <p>
                Voor het vullen van de CHEMtrend database is gebruik gemaakt van de meetdata van chemische stoffen afkomstig van de Landelijke Enquête Waterkwaliteit (LEW) en beschikbaar gemaakt via het Informatiehuis Water – Waterkwaliteitsportaal (meer informatie via <a href="https://www.waterkwaliteitsportaal.nl/" target="_blank">https://www.waterkwaliteitsportaal.nl/</a>). Dit betreft data voor MNLSO-meetlocaties in de regionale wateren. Aanvullend is voor de Rijkswateren meetdata toegevoegd die afkomstig is van Rijkswaterstaat en ook beschikbaar is via <a href="https://waterinfo.rws.nl" target="_blank">waterinfo.rws.nl</a>. De CHEMtrend database wordt jaarlijks bijgewerkt met recente monitoringsdata uit genoemde onderliggende databases.
              </p>
              <h3 class="mt-4 font-italic">Trendbepaling</h3>
              <p>
                Voor de individuele meetlocaties zijn drie verschillende trendbepalingen uitgevoerd:
              </p>
              <ol>
                <li>De Seasonal Mann Kendall trendtest (Hirsch and Slack 1984) is een statistische test die aangeeft of er een significante opwaartse of neerwaartse trend in de gegevens aanwezig is.</li>
                <li>De Theil-Sen hellingschatter (Hirsch et al. 1982) is een methode waarmee de mediane trendhelling met het 95% betrouwbaarheidsinterval wordt bepaald.</li>
                <li>De LOWESS-trendlijn (Cleveland 1979) trekt een globale kromme een soort lokale mediaan door de meetgegevens waardoor een trendlijn ontstaat die bijvoorbeeld kan afvlakken als een trend niet doorzet.</li>
              </ol>
              <p class="mt-3">
                Een meetpunt-stof combinatie (bijvoorbeeld Zink in AMSDM) is als ‘trendgeschikt’ beoordeeld, indien de meetreeks aan onderstaande criteria voldoet:
              </p>
              <ol>
                <li>Minimaal 4 metingen per jaar en minimaal 50% boven de rapportagegrens.</li>
                <li>Minimaal 5 jaar data en 1 van die jaren in de afgelopen 3 jaar.</li>
                <li>Verwijdering begindata bij parameter-meetpunt combinaties met een data gat van meer dan 9 jaar.</li>
              </ol>
              <p class="mt-3">
                Meer informatie over de gepresenteerde data en trendberekening is terug te vinden in de volgende rapportage:
              </p>
              <ul>
                <li>Trends in waterkwaliteit (<a href="https://publications.deltares.nl/11210346_011_0001.pdf" target="_blank">hier downloaden</a>)</li>
              </ul>
              <h3 class="mt-4 font-italic">Gebruik</h3>
              <p>
                Uit de getoonde keuzelijst kan de gebruiker één of meerdere stoffen selecteren. Momenteel zijn er een beperkt aantal stoffen opgenomen in de CHEMtrend database. Op termijn wordt deze lijst verder uitgebreid. Na selectie van een stof verschijnt er in de kaartlaag een overzicht van alle meetlocaties. Aan de hand van achtergrondkaarten kan de gebruiker inzoomen op een bepaald KRW-waterlichaam, stroomgebied of waterschap en bekijken welke locatie(s) er binnen het geselecteerde domein beschikbaar zijn. Na selectie van een meetlocatie zal een trendgrafiek getoond worden voor de geselecteerde stof(fen).
              </p>
              <p>
                Het gebruik van deze meetdata en trendgrafieken is onderworpen aan de Gebruiksvoorwaarden.
              </p>
              <h3 class="mt-4 font-italic">Nuttige links naar andere webviewers</h3>
              <ul>
                <li><a href="https://krw-nutrend.netlify.app" target="_blank">krw-nutrend.netlify.app</a>: Voor nutriënten (stikstof, fosfor en DIN) wordt voor verschillende toetsjaren de toestand, trends, concentraties, en afstand tot de norm(doelgat) getoond voor de KRW-waterlichamen in Nederland.</li>
                <li><a href="https://www.bestrijdingsmiddelenatlas.nl" target="_blank">www.bestrijdingsmiddelenatlas.nl</a>: Voor een uitgebreide lijst van bestrijdingsmiddelen is in diverse kaartlagen de mate van overschrijding per stof, landgebruik en jaar weergegeven.</li>
              </ul>
            </v-card-text>
          </v-card>
        </v-dialog>
      </v-row>
    </v-col>
  </div>
</template>

<script>

import pdfFile from '@/assets/Trends_in_waterkwaliteit_eindconceptrapport_20240703_forDemoCHEMtrendWebApplication.pdf'

export default {
  data () {
    return {
      dialog: false,
      pdfLink: pdfFile
    }
  }
}
</script>
