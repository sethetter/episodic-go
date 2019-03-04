package episodic

// TV is a TV data object from the TMDB API.
type TV struct {
	ID          int      `json:"id"`
	Seasons     []Season `json:"seasons"`
	NextEpisode Episode  `json:"next_episode_to_air,omitempty"`
}
