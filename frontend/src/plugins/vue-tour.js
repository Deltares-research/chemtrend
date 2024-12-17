import VueTour from 'vue-tour'
import 'vue-tour/dist/vue-tour.css'

// Export the components manually
export const VTour = VueTour.VTour
export const VStep = VueTour.VStep

// Export the generateTourSteps function for your steps
export const tourStepCount = null

export const generateTourSteps = () => ([
  {
    target: '[data-v-step="1"]',
    content: 'Tour step 1',
    params: { enableScrolling: false, placement: 'top' }
  },
  {
    target: '[data-v-step="2"]',
    content: 'Tour step 2',
    params: { enableScrolling: false, placement: 'top' }
  },
  {
    target: '[data-v-step="3"]',
    content: 'Tour step 3',
    params: { enableScrolling: false, placement: 'right' }
  }
])

// Custom plugin to register components
export default {
  install (app) {
    // Register the extracted components globally
    app.component('VTour', VTour)
    app.component('VStep', VStep)
  }
}
