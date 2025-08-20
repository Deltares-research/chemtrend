// order is important, because the last object will show on top of the map
export const visualizationComponents = {
  notrend: {
    color: '#fff27aff',
    shape: 'notrend_square',
    name: 'Te weinig gegevens voor een trend'
  },
  inconclusive: {
    color: '#dddddd',
    shape: 'inconclusive_circle',
    name: 'Geen trend'
  },
  upwards: {
    color: '#c26a77',
    shape: 'upwards_triangle',
    name: 'Stijgende trend'
  },
  downwards: {
    color: '#94cbec',
    shape: 'downwards_triangle',
    name: 'Dalende trend'
  }
}
