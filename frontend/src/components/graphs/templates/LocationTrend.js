import { visualizationComponents } from '@/utils/colors'
import _ from 'lodash'

export function LocationTemplate (trendData, selectedColor) {
  const zip = (a1, a2) => a1.map((x, i) => [x, a2[i]])
  const zippedMetingData = zip(trendData.x_value, trendData.y_value_meting)
  const marklines = []
  if (trendData.h1_value) {
    marklines.push({
      yAxis: trendData.h1_value,
      name: trendData.h1_label,
      label: {
        formatter: params => params.data.name
      }
    })
  }
  if (trendData.h2_value) {
    marklines.push({
      yAxis: trendData.h2_value,
      name: trendData.h2_label,
      label: {
        formatter: params => params.data.name
      }
    })
  }
  const color = _.get(visualizationComponents[trendData.trend_direction], 'color', visualizationComponents.downwards.color)

  return {
    title: {
      text: trendData.title,
      subtext: `${trendData.subtitle_1}\n${trendData.subtitle_2}`,
      left: 'center',
      textStyle: {
        fontSize: 17
      },
      subtextStyle: {
        fontSize: 12,
        lineHeight: 18
      }
    },
    animation: false,
    grid: {
      bottom: 60,
      right: 40,
      left: 40,
      top: 50
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
        saveAsImage: {},
        dataView: { readOnly: false }
      }
    },
    legend: {
      show: true,
      bottom: 5,
      lineStyle: {
        symbol: 'none'
      },
      itemWidth: 70
    },
    xAxis: {
      type: 'time',
      axisLabel: {
        formatter: '{MMM}-{yyyy}',
        showMinLabel: true,
        showMaxLabel: true
      }
    },
    yAxis: {
      type: 'value',
      name: `[${trendData.unit}]`
    },
    series: [
      {
        name: 'Meting',
        type: 'line',
        data: zippedMetingData,
        lineStyle: {
          color: selectedColor
        },
        symbol: 'circle',
        symbolSize: (_, params) => {
          if (trendData.point_filled === undefined) { return 4 }
          return trendData.point_filled[params.dataIndex] ? 4 : 0
        },
        itemStyle: {
          color: '#f8766d',
          borderColor: '#000000',
          borderWidth: 1
        },
        markLine: {
          data: marklines,
          emphasis: {
            disabled: true
          },
          lineStyle: {
            color: '#373737'
          },
          symbol: ['none', 'none'],
          tooltip: {
            show: true,
            formatter: params => `${params.data.xAxis}  ${params.data.yAxis}`
          }
        }
      },
      createLagerDanRapportagegrens(zippedMetingData, selectedColor, trendData),
      {
        name: 'Lowess',
        type: 'line',
        data: zip(trendData.x_value, trendData.y_value_lowess),
        lineStyle: {
          color: color
        },
        symbol: 'none',
        itemStyle: { color: 'transparent' }
      },
      {
        name: 'Theil Sen',
        type: 'line',
        data: zip(trendData.x_value, trendData.y_value_theil_sen),
        lineStyle: {
          color: '#FFA500',
          type: 'dashed'
        },
        symbol: 'none',
        itemStyle: { color: 'transparent' }
      }
    ]
  }
}

function createLagerDanRapportagegrens (zippedMetingData, selectedColor, trendData) {
  if (trendData.point_filled === undefined || trendData.point_filled.filter(filled => !filled).length === 0) {
    return undefined
  }
  return {
    name: 'Lager dan rapportagegrens',
    type: 'line',
    data: zippedMetingData,
    itemStyle: {
      color: 'transparent',
      borderColor: '#000000',
      borderWidth: 1
    },
    lineStyle: {
      color: selectedColor
    },
    symbol: 'circle',
    showSymbol: true,
    symbolSize: (_, params) => {
      return !trendData.point_filled[params.dataIndex] ? 4 : 0
    }
  }
}
