<template>
  <div class="map-legend">
    <div class="legend-item">
      <span class="legend-color-data-unselected" :style="{ border: '1px solid #000000' }"></span>
      <span class="legend-label">Stof niet geselecteerd / Geen data beschikbaar</span>
    </div>
    <div class="legend-item">
      <span class="legend-color-data-up" :style="{ border: '1px solid #000000' }"></span>
      <span class="legend-label">Dalende trend</span>
    </div>
    <div class="legend-item">
      <span class="legend-color-data-down" :style="{ border: '1px solid #000000' }"></span>
      <span class="legend-label">Stijgende trend</span>
    </div>
    <div class="legend-item">
      <span class="legend-color-data-neutral" :style="{ border: '1px solid #000000' }"></span>
      <span class="legend-label">Geen significante trend</span>
    </div>
  </div>
</template>

<script>
export default {
  name: 'LocationsLegend'
}
</script>

<style scoped>
.map-legend {
  position: relative;
  top: 15px;
  background: rgba(255, 255, 255, 0.8);
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
}
.legend-color-data-unselected {
  width: 10px;
  height: 10px;
  margin-right: 10px;
  background-color: white;
  border-radius: 50%;
}

.legend-color-data-up {
  width: 10px;
  height: 10px;
  margin-right: 10px;
  background-color: green;
  border-radius: 50%;
}

.legend-color-data-down {
  width: 10px;
  height: 10px;
  margin-right: 10px;
  background-color: red;
  border-radius: 50%;
}

.legend-color-data-neutral {
  width: 10px;
  height: 10px;
  margin-right: 10px;
  background-color: grey;
  border-radius: 50%;
}

.legend-label {
  font-size: 12px;
  color: #333;
}
</style>
