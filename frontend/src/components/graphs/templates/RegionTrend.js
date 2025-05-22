import _ from 'lodash'
import { visualizationComponents } from '@/utils/colors'

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
    yAxis: {
      type: 'value',
      name: `[${trendData.unit}]`
    },
    xAxis: { 
      type: 'time',
      axisLabel: {
        formatter: '{MMM}-{yyyy}',
        showMinLabel: true,
        showMaxLabel: true
      }
     },
    series: trendData.locations.map(loc => {
      const color = _.get(visualizationComponents[loc.trend_direction], 'color', visualizationComponents.downwards.color)
      console.log('my trendData: ', trendData)
      let lineStyle = {
        color: color,
        opacity: 0.4
      }
      let name = _.get(visualizationComponents[loc.trend_direction], 'name', visualizationComponents.downwards.name)

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
