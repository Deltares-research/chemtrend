<template>
    <v-dialog v-model="dialog" persistent max-width="600px">
      <v-card>
        <v-card-title class="headline">Disclaimer</v-card-title>
        <v-card-text>
          <p>
            Welcome to our website. Please read the following disclaimer carefully before using this site.
          </p>
          <p>
            By accessing or using this website, you agree to be bound by the terms and conditions described in this disclaimer. If you do not agree to these terms, please do not use this website.
          </p>
          <p>
            The information provided on this website is for general informational purposes only. We make no representations or warranties of any kind, express or implied, about the completeness, accuracy, reliability, suitability, or availability with respect to the website or the information, products, services, or related graphics contained on the website for any purpose. Any reliance you place on such information is therefore strictly at your own risk.
          </p>
          <p>
            In no event will we be liable for any loss or damage including without limitation, indirect or consequential loss or damage, or any loss or damage whatsoever arising from loss of data or profits arising out of, or in connection with, the use of this website.
          </p>
          <p>
            Through this website, you may be able to link to other websites which are not under our control. We have no control over the nature, content, and availability of those sites. The inclusion of any links does not necessarily imply a recommendation or endorse the views expressed within them.
          </p>
          <p>
            Every effort is made to keep the website up and running smoothly. However, we take no responsibility for, and will not be liable for, the website being temporarily unavailable due to technical issues beyond our control.
          </p>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn color="primary" @click="acknowledgeDisclaimer">I Acknowledge</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </template>

<script>
import { mapState, mapActions } from 'vuex'

export default {
  name: 'Disclaimer',
  data () {
    return {
      dialog: !this.disclaimerAcknowledged
    }
  },
  computed: {
    ...mapState(['disclaimerAcknowledged'])
  },
  watch: {
    disclaimerAcknowledged (value) {
      if (value) {
        this.dialog = false
      }
    }
  },
  methods: {
    ...mapActions(['saveDisclaimerAcknowledgment', 'loadDisclaimerAcknowledgment']),
    acknowledgeDisclaimer () {
      this.saveDisclaimerAcknowledgment(true)
    }
  }
}
</script>
