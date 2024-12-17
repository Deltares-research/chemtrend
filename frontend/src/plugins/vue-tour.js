import VueTour from 'vue-tour'
import 'vue-tour/dist/vue-tour.css'

export let tourStepCount = null

export const generateTourSteps = (data) => ([
  {
    target: '[data-v-step="1"]',
    content: 'Tour step 1',
    params: {
      enableScrolling: false,
      placement: 'bottom'
    },
    before: function () {
      tourStepCount = 1
    }
  },
  {
    target: '[data-v-step="2"]',
    content: 'Tour step 2',
    params: {
      enableScrolling: false,
      placement: 'top'
    },
    before: function () {
      tourStepCount = 2
    }
  },
  {
    target: '[data-v-step="3"]',
    content: 'Tour step 3',
    params: {
      enableScrolling: false,
      placement: 'right',
      modifiers: {
        offset: {
          enabled: true,
          offset: '0, 0'
        }
      }
    },
    before: function () {
      tourStepCount = 3
    }
  },
  {
    target: '[data-v-step="4"]',
    content: 'Tour step 4',
    params: {
      enableScrolling: false,
      placement: 'left',
      modifiers: {
        offset: {
          enabled: true,
          offset: '0, 0'
        }
      }
    },
    before: function () {
      tourStepCount = 4
    }
  },
  {
    target: '[data-v-step="5"]',
    content: 'Tour step 5',
    params: {
      enableScrolling: false,
      placement: 'bottom'
    },
    before: function () {
      tourStepCount = 5
    }
  },
  {
    target: '[data-v-step="6"]',
    content: 'Tour step 6',
    params: {
      enableScrolling: false,
      placement: 'bottom'
    },
    before: function () {
      tourStepCount = 6
    }
  },
  {
    target: '[data-v-step="7"]',
    content: 'Tour step 7',
    params: {
      enableScrolling: false,
      placement: 'bottom'
    },
    before: function () {
      tourStepCount = 7
    }
  }
])

export default {
  install: (app) => {
    app.component('VTour', VueTour.VTour)
    app.component('VStep', VueTour.VStep)

    app.config.globalProperties.$tours = VueTour
  }
}
