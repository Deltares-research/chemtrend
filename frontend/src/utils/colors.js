// order is important, because the last object will show on top of the map
export const visualizationComponents = {
  notrend: {
    color: '#dddddd',
    shape: 'notrend_circle',
    name: 'Te weinig metingen voor een trend'
  },
  inconclusive: {
    color: '#E7DD87',
    shape: 'inconclusive_square',
    name: 'Geen significante trend'
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
