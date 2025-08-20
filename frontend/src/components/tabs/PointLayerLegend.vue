<template>
  <div class="map-legend">
    <div class="legend-item" @click="handleClick('locations')">
      <span class="legend-color-data-unselected" :style="{ border: '1px solid #000000' }"></span>
      <span :class="getLabelClass('locations')" class="legend-label">Stof niet geselecteerd / Geen data beschikbaar</span>
    </div>
    <div class="legend-item" @click="handleClick('filtered-locations-downwards')">
      <img src="./img/icons/downwards_triangle.png" alt="blue downwards triangle" class="legend-triangle" />
      <span :class="getLabelClass('filtered-locations-downwards')" class="legend-label">Dalende trend</span>
    </div>
    <div class="legend-item" @click="handleClick('filtered-locations-upwards')">
      <img src="./img/icons/upwards_triangle.png" alt="red  upwards triangle" class="legend-triangle" />
      <span :class="getLabelClass('filtered-locations-upwards')" class="legend-label">Stijgende trend</span>
    </div>
    <div class="legend-item" @click="handleClick('filtered-locations-inconclusive')">
      <span class="legend-color-data-neutral" :style="{ border: '1px solid #000000' }"></span>
      <span :class="getLabelClass('filtered-locations-inconclusive')" class="legend-label" >Geen significante trend</span>
    </div>
    <div class="legend-item" @click="handleClick('filtered-locations-notrend')">
      <span class="legend-color-notrend" :style="{ border: '1px solid #000000' }"></span>
      <span :class="getLabelClass('filtered-locations-notrend')" class="legend-label" >Te weinig gegevens voor een trend</span>
    </div>
  </div>
</template>

<script>
import { visualizationComponents } from '../../utils/colors.js'
export default {
  name: 'LocationsLegend',
  data () {
    return {
      visibility: {
        locations: true,
        'filtered-locations-downwards': true,
        'filtered-locations-upwards': true,
        'filtered-locations-inconclusive': true,
        'filtered-locations-notrend': true
      }
    }
  },
  mounted () {
    const legend = this.$el.closest('.map-legend') || this.$el
    legend.style.setProperty('--inconclusive-color', visualizationComponents.inconclusive.color)
    legend.style.setProperty('--notrend-color', visualizationComponents.notrend.color)
  },
  methods: {
    handleClick (type) {
      this.$emit('legend-click', type)
      this.visibility[type] = !this.visibility[type]
    },
    getLabelClass (type) {
      return this.visibility[type] ? '' : 'greyed-out'
    }
  }
}
</script>

<style scoped>
.map-legend {
  position: relative;
  top: 15px;
  background: rgba(255, 255, 255);
  padding: 10px;
  margin-inline: 15px;
  border-radius: 5px;
  font-family: Arial, sans-serif;
  font-size: 12px;
  box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
}

.legend-item {
  display: flex;
  align-items: center;
  margin-bottom: 5px;
  cursor: pointer;
}

.legend-item:hover {
  background-color: #f0f0f0; /* Add hover effect */
}

.legend-color-data-unselected {
  width: 10px;
  height: 10px;
  margin-right: 10px;
  background-color: white;
  border-radius: 50%;
  margin-left: 3px;
}

.legend-triangle {
  width: 15px;
  height: 15px;
  margin-right: 7px;
}

.legend-color-data-neutral {
  width: 10px;
  height: 10px;
  margin-right: 10px;
  background-color: var(--inconclusive-color, #dddddd);
  border-radius: 50%;
  margin-left: 3px;
}

.legend-color-notrend {
  width: 10px;
  height: 10px;
  margin-right: 10px;
  background-color: var(--notrend-color);
  margin-left: 3px;
}

.legend-label {
  font-size: 12px;
  color: #333;
}

.greyed-out {
  color: #999;
}
</style>
