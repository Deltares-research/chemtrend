import _ from 'lodash'

/* eslint-disable */
export function RegionTemplate (trendData) {
  console.log(trendData.locations)
  return {
    title: {
      text: trendData.title,
      left: 'center',
      textStyle: {
        fontSize: 17
      },
      subtextStyle: {
        fontSize: 12
      }
    },
    grid: {
      bottom: 50,
      right: 50,
      left: 50
    },
    tooltip: {
      show: true
    },
    toolbox: {
      right: 10,
      feature: {
        dataZoom: {
          yAxisIndex: 'none'
        },
        restore: {},
        saveAsImage: {}
      }
    },
    legend: {
      show: true,
      bottom: 5,
      lineStyle: {
        symbol: 'none'
      },
      itemWidth: 70,
      data: ['Upward trend']
    },
    yAxis: {},
    xAxis: { type: 'time' },
    series: trendData.locations.map(loc => {
      const color = loc.color || 'green'
      let lineStyle = {
        color: loc.color || 'green',
        opacity: 0.2
      }
      let name = 'Neerwaartse trend'
      if (color === 'green') {
        name = 'Stijgende trend'
      }
      if (trendData.title.includes(loc.trend_label)) {
        lineStyle = {
          color: 'black'
        }
      }
      return {
        name: loc.trend_label,
        type: 'line',
        data: _.zip.apply(_, [loc.x_value, loc.y_value_lowess]),
        symbol: 'none',
        lineStyle
      }
    })
  }
}
