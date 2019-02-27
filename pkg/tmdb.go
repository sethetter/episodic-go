package episodic

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
)

var (
	apiBase = "https://api.themoviedb.org/3"
)

// TMDB is responsible for communicating with the TMDB API.
type TMDB struct {
	*http.Client
	Key string
}

// NewTMDBClient creates an http client for communicating with the TMDB API.
func NewTMDBClient(key string) *TMDB {
	return &TMDB{
		Client: http.DefaultClient,
		Key:    key,
	}
}

// GetTV returns TV show data for a given TV ID.
func (t *TMDB) GetTV(showID int) (*TV, error) {
	url := fmt.Sprintf("%s/tv/%d?api_key=%s", apiBase, showID, t.Key)

	resp, err := t.Get(url)
	if err != nil {
		return &TV{}, err
	}

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return &TV{}, err
	}

	var show TV
	err = json.Unmarshal(body, &show)
	if err != nil {
		return &TV{}, err
	}

	return &show, nil
}

// TV is a TV data object from the TMDB API.
type TV struct {
	ID          int      `json:"id"`
	NextEpisode string   `json:"next_episode_to_air"`
	Seasons     []Season `json:"seasons"`
}

// MostRecentSeason gets the most recent season from a TV struct.
func (s *TV) MostRecentSeason() {
	latest := s.Seasons[0]

	for _, s := range s.Seasons {
		if s.Number > latest.Number {
			latest = s
		}
	}

	return s.ID
}

// Season represents a TV Season data object from TMDB.
type Season struct {
	ID       int       `json:"id"`
	AirDate  string    `json:"air_date"`
	Number   int       `json:"season_number"`
	Episodes []Episode `json:"episodes,omitempty"`
}

// Episode represents a TV Episode object from TMDB.
type Episode struct {
	ID      int    `json:"id"`
	AirDate string `json:"air_date"`
	Number  int    `json:"episode_number"`
}

// DaysFromAir returns the number of days from the AirDate.
func (e *Episode) DaysFromAir() (int, error) {

}
