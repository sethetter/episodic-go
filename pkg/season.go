package episodic

// Season represents a TV Season data object from TMDB.
type Season struct {
	ID       int       `json:"id"`
	AirDate  string    `json:"air_date"`
	Number   int       `json:"season_number"`
	Episodes []Episode `json:"episodes,omitempty"`
}
