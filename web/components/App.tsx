import preact, { render, Component } from 'preact'
import { removeEpisode } from '../api'

import { IEpisode } from '../types'
import EpisodeLI from './EpisodeLI'

interface AppProps {
  episodes: IEpisode[]
}

export default class App extends Component<AppProps, AppProps> {
  constructor({ episodes }: AppProps) {
    super()
    this.setState({ episodes })
  }

  markEpisodeAsWatched (id: number) {
    return (evt: Event) => {
      evt.preventDefault()
      if (window.confirm('Are you shoooooore?')) {
        removeEpisode(id).then(newEpisodes => {
          this.setState({ episodes: newEpisodes })
        })
      }
    }
  }

  render() {
    const sortedEpisodes = this.state.episodes.sort((a, b) => {
      return a.air_date > b.air_date ? 1 : -1
    })

    return (
      <div>
        <h1>Episodic</h1>
        <ul className="episodes">
          {sortedEpisodes.map(ep => <EpisodeLI episode={ep} removeClickHandler={this.markEpisodeAsWatched(ep.id)} />)}
        </ul>
      </div>
    )
  }
}
