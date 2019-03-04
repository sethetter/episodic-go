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
	fmt.Println(string(body))
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
