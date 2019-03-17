import preact from 'preact'

/** @jsx preact.h */

const DATA = {
  episodes: [
    {
      link: 'https://some.link/to-the-episode',
      show: 'Game of Thrones',
      number: 1,
      season: 1,
      date: '2019-03-31'
    },
    {
      link: 'https://some.link/to-the-episode',
      show: 'Game of Thrones',
      number: 2,
      season: 1,
      date: '2019-04-02'
    },
    {
      link: 'https://some.link/to-the-episode',
      show: 'Crashing',
      number: 3,
      season: 5,
      date: '2019-03-26'
    },
    {
      link: 'https://some.link/to-the-episode',
      show: 'Crashing',
      number: 1,
      season: 5,
      date: '2019-03-01'
    },
    {
      link: 'https://some.link/to-the-episode',
      show: 'Crashing',
      number: 2,
      season: 5,
      date: '2019-03-08'
    }
  ]
}

const renderEpisode = (ep) => (
  <li>
    {episodeWatchedLink(ep)}
    &nbsp;
    {episodeInfo(ep)}
  </li>
)

const episodeInfo = (ep) => (
  `${ep.show}: S${ep.season}, E${ep.number} (${ep.date})`
)

const episodeWatchedLink = (ep) => (
  <a href="#" onClick={markEpisodeAsWatched(ep.id)}>[X]</a>
)

const markEpisodeAsWatched = (id) => (evt) => {
  evt.preventDefault()
  if (window.confirm('Are you shoooooore?')) {
    removeEpisode(id).then(render)
  }
}

function removeEpisode (id) {
  return new Promise((resolve, reject) => {
    // fetch URL
    // on successful response, resolve with transformed response
    resolve(DATA.episodes)
  })
}

// function getEpisodes () {}

function render (episodes) {
  const sortedEpisodes = episodes.sort((a, b) => a.date > b.date ? 1 : -1)
  preact.render((
    <div>
      <h1>Episodic</h1>
      <ul>
        {sortedEpisodes.map(renderEpisode)}
      </ul>
    </div>
  ), document.getElementById('main'))
}

render(DATA.episodes)
