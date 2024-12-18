
export function LocationTemplate (trendData, selectedColor) {
  const zip = (a1, a2) => a1.map((x, i) => [x, a2[i]])
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

  return {
    title: {
      text: trendData.title,
      subtext: `${trendData.subtitle_1}\n${trendData.subtitle_2}`,
      left: 'center',
      textStyle: {
        fontSize: 17
      },
      subtextStyle: {
        fontSize: 12
      }
    },
    animation: false,
    grid: {
      bottom: 60,
      right: 40,
      left: 30,
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
        formatter: '{yyyy}',
        showMinLabel: true,
        showMaxLabel: true
      }
    },
    yAxis: {
      type: 'value'
    },
    series: [
      {
        name: 'Meting',
        type: 'line',
        data: zip(trendData.x_value, trendData.y_value_meting),
        lineStyle: {
          color: selectedColor
        },
        symbol: 'circle',
        symbolSize: 4,
        showAllSymbol: true,
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
            formatter: params => `${params.data.name}  ${params.data.yAxis}`
          }
        }
      },
      {
        name: 'Lowess',
        type: 'line',
        data: zip(trendData.x_value, trendData.y_value_lowess),
        lineStyle: {
          color: trendData.color
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
