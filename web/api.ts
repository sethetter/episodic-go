const API_BASE = 'https://episodic-api.n0pe.lol'
import { IEpisode } from './types'

interface WatchlistResponse {
  watch_list: IEpisode[]
}

async function epsFromWatchlistResponse (res: Response): Promise<IEpisode[]> {
  const body = await res.json()
  return body.watch_list
}

export async function getEpisodes (): Promise<IEpisode[]> {
  const resp = await fetch(`${API_BASE}/watchlist`)
  return epsFromWatchlistResponse(resp)
}

export async function removeEpisode (id: number): Promise<IEpisode[]> {
  const resp = await fetch(`${API_BASE}/rmepisode?id=${id}`)
  return epsFromWatchlistResponse(resp)
}
