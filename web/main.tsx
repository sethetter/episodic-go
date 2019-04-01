import preact, { render } from 'preact'
import { getEpisodes } from './api'

import App from './components/App'

// TODO: convert away from parcel and use ESM's, plus pika?
getEpisodes().then(episodes => {
  render(<App episodes={episodes} />, document.getElementById('main') as Element)
})
