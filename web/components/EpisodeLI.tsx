import preact from 'preact'
import { IEpisode } from '../types'

interface EpisodeLIProps {
  episode: IEpisode
  removeClickHandler: (id: number) => (evt: Event) => void
}

const EpisodeLI = ({ episode, removeClickHandler }: EpisodeLIProps) => {
  const episodeInfo = (ep: IEpisode) => (
    `${ep.show_name}: S${ep.season_number}, E${ep.episode_number} (${ep.air_date})`
  )

  const episodeWatchedLink = (ep: IEpisode) => (
    <button onClick={removeClickHandler(ep.id)}>X</button>
  )

  return (
    <li className="episode-li">
      <span>{episodeWatchedLink(episode)}</span>
      {episodeInfo(episode)}
    </li>
  )
}

export default EpisodeLI
