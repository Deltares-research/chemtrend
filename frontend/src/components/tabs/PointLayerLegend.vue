<template>
  <div class="map-legend">
    <div class="legend-item">
      <span class="legend-color-data" :style="{ border: '1px solid #000000' }"></span>
      <span class="legend-label">Measurement data available</span>
    </div>
    <div class="legend-item">
      <span class="legend-color-no-data"></span>
      <span class="legend-label">No measurement data available</span>
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
  top: 10px;
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

.legend-color-data {
  width: 10px;
  height: 10px;
  margin-right: 10px;
  background-color: #57b146;
  border-radius: 50%;
}

.legend-color-no-data {
  width: 10px;
  height: 10px;
  margin-right: 10px;
  background-color: #000000;
  border-radius: 50%;
}

.legend-label {
  font-size: 12px;
  color: #333;
}
</style>
