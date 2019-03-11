package episodic

// TV is a TV data object from the TMDB API.
type TV struct {
	ID          int      `json:"id"`
	Name        string   `json:"name"`
	Seasons     []Season `json:"seasons,omitempty"`
	NextEpisode *Episode `json:"next_episode_to_air,omitempty"`
}

// HasNextEpisode will return false if there is no next episode for a TV struct.
func (tv *TV) HasNextEpisode() bool {
	if tv.NextEpisode == nil {
		return false
	}
	return true
}
