export function template (trendData) {
    return {
      title: {
        text: trendData.title,
        subtext: `${trendData.subtitle_1}\n${trendData.subtitle_2}`,
        left: 'center',
        top: 10,
        textStyle: {
          fontSize: 25
        },
        subtextStyle: {
          fontSize: 15
        }
      },
      grid: {
        top: 100,
        bottom: 50,
        right: 50,
        left: 50
      },
      tooltip: {
        show: true
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
            color: '#000000'
          },
          symbol: 'circle',
          symbolSize: 8,
          showAllSymbol: true,
          itemStyle: {
            color: '#f8766d',
            borderColor: '#000000',
            borderWidth: 1
          },
          markLine: {
            data: [
              {
                yAxis: trendData.h1_value,
                name: trendData.h1_label,
                label: {
                  show: true,
                  position: 'insideStart',
                  formatter: params => params.data.name
                }
              },
              {
                yAxis: trendData.h2_value,
                name: trendData.h2_label,
                label: {
                  show: true,
                  position: 'insideEnd',
                  formatter: params => params.data.name
                }
              }
            ],
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
            color: '#0000ff'
          },
          symbol: 'none',
          showSymbol: false
        },
        {
          name: 'Theil Sen',
          type: 'line',
          data: trendData.y_value_theil_sen,
          lineStyle: {
            color: '#FFA500',
            type: 'dashed'
          },
          symbol: 'none',
          showSymbol: false,
          itemStyle: {
            color: '#FFA500'
          }
        }
      ]
    }
}