export function LocationTemplate (trendData, selectedColor) {
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

  let lowessColor = 'red'
  if (trendData.subtitle_1.includes('geen')) {
    lowessColor = 'grey'
  }
  if (trendData.subtitle_1.includes('neerwaarts')) {
    lowessColor = 'green'
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
        saveAsImage: {}
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
      type: 'category',
      data: trendData.x_value
    },
    yAxis: {
      type: 'value'
    },
    series: [
      {
        name: 'Meting',
        type: 'line',
        data: trendData.y_value_meting,
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
        data: trendData.y_value_lowess,
        lineStyle: {
          color: lowessColor
        },
        itemStyle: {
          color: 'transparent'
        }
      },
      {
        name: 'Theil Sen',
        type: 'line',
        data: trendData.y_value_theil_sen,
        lineStyle: {
          color: '#FFA500',
          type: 'dashed'
        },
        itemStyle: {
          color: '#FFA500'
        }
      }
    ]
  }
}
