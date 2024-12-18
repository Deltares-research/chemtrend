import _ from 'lodash'

/* eslint-disable */
export function RegionTemplate (trendData, titleColor, selectedColor, currentLocation) {
  return {
    title: {
      text: trendData.title,
      left: 'center',
      textStyle: {
        fontSize: 17,
        color: titleColor
      },
      subtextStyle: {
        fontSize: 12
      }
    },
    legend: {
      show: true,
      bottom: 0,
      itemStyle: {
        color: 'transparent'
      }
    },
    grid: {
      bottom: 60,
      right: 40,
      left: 30,
      top: 30
    },
    tooltip: {
      show: true,
      trigger: 'item',
    },
    toolbox: {
      right: 10,
      feature: {
        dataZoom: {
          yAxisIndex: 'none'
        },
        restore: {},
        saveAsImage: {},
        dataView: { readOnly: false }
      }
    },
    yAxis: {},
    xAxis: { type: 'time' },
    series: trendData.locations.map(loc => {
      const color = loc.color || 'green'
      let lineStyle = {
        color: loc.color || 'green',
        opacity: 0.2
      }
      let name = 'Stijgende trend'
      if (color === 'green') {
        name = 'Dalende trend'
      }
      if (color === 'grey') {
        name = 'Geen Trend'
      }

      if (loc.trend_label === currentLocation) {
        lineStyle = {
          color: selectedColor
        }
        name = currentLocation
      }

      if (loc.trend_label === 'p50') {
        name = loc.trend_label
        lineStyle = {
          color: 'black'
        }
      }

      if (loc.trend_label === 'p25' || loc.trend_label === 'p75') {
        name = loc.trend_label
        lineStyle = {
          color: 'grey',
          type: 'dashed'
        }
      }
      return {
        name: name,
        type: 'line',
        data: _.zip.apply(_, [loc.x_value, loc.y_value_lowess]),
        symbol: 'none',
        lineStyle
      }
    })
  }
}
