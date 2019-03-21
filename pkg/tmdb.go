package episodic

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
)

var (
	apiBase = "https://api.themoviedb.org/3"
)

// TMDB is responsible for communicating with the TMDB API.
type TMDB struct {
	*http.Client
	Key  string
	Base string
}

// NewTMDBClient creates an http client for communicating with the TMDB API.
func NewTMDBClient(key string) *TMDB {
	return &TMDB{
		Client: http.DefaultClient,
		Key:    key,
		Base:   apiBase,
	}
}

// GetTV returns TV show data for a given TV ID.
func (t *TMDB) GetTV(showID int) (*TV, error) {
	url := fmt.Sprintf("%s/tv/%d?api_key=%s", t.Base, showID, t.Key)

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

	if show.HasNextEpisode() {
		show.NextEpisode.ShowName = show.Name
	}

	return &show, nil
}

type searchTVResponse struct {
	Results      []TV `json:"results"`
	TotalResults int  `json:"total_results"`
}

// SearchTV searches for a show and returns the first result.
func (t *TMDB) SearchTV(query string) (*TV, error) {
	query = strings.Replace(query, " ", "+", -1)
	url := fmt.Sprintf("%s/search/tv?query=%s&api_key=%s", t.Base, query, t.Key)

	resp, err := t.Get(url)
	if err != nil {
		return &TV{}, fmt.Errorf("error during GET: %v", err)
	}

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return &TV{}, fmt.Errorf("error reading body: %v", err)
	}

	var response searchTVResponse
	err = json.Unmarshal(body, &response)
	if err != nil {
		return &TV{}, fmt.Errorf("error unmarshalling response body: %v", err)
	}

	if response.TotalResults == 0 {
		return &TV{}, fmt.Errorf("no shows returned for query: %s", query)
	}

	return &response.Results[0], nil
}
