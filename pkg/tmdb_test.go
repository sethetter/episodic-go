package episodic_test

import (
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"

	episodic "github.com/sethetter/episodic/pkg"
)

func TestGetTV(t *testing.T) {
	id := 123
	epID := 1234
	epNumber := 9
	airDate := "2019-02-09"
	wantPath := fmt.Sprintf("/tv/%d", id)

	s := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != wantPath {
			t.Fatalf("incorrect url: %s, want %s", r.URL.Path, wantPath)
		}

		w.Header().Set("content-type", "application/json")
		fmt.Fprintln(w, fmt.Sprintf(`{
			"id": %d,
			"seasons": [],
			"next_episode_to_air": {
				"id": %d,
				"air_date": "%s",
				"episode_number": %d
			}
		}`, id, epID, airDate, epNumber))
	}))
	defer s.Close()

	tmdb := &episodic.TMDB{
		Client: s.Client(),
		Key:    "SUP",
		Base:   s.URL,
	}

	show, err := tmdb.GetTV(id)

	if err != nil {
		t.Errorf("Unexpected error: %v", err)
	}
	if show.ID != id {
		t.Fatalf("Show ID does not match, expected %v, got %v", id, show.ID)
	}
	if show.NextEpisode.AirDate != airDate {
		t.Fatalf("Next episode air date does not match, expected %v, got %v", id, show.ID)
	}
	if show.NextEpisode.Number != epNumber {
		t.Fatalf("Next episode number does not match, expected %v, got %v", id, show.ID)
	}
	if show.NextEpisode.ID != epID {
		t.Fatalf("Next episode ID does not match, expected %v, got %v", id, show.ID)
	}
}

func TestSearchTV(t *testing.T) {
	showID := 123
	name := "Some Show"
	wantPath := "/search/tv"

	s := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != wantPath {
			t.Fatalf("incorrect url: %s, want %s", r.URL.Path, wantPath)
		}

		w.Header().Set("content-type", "application/json")
		fmt.Fprintln(w, fmt.Sprintf(`{
			"results": [{
				"id": %d,
				"name": "%s"
			}, {
				"id": 0,
				"name": "Not the right one"
			}],
			"page": 1,
			"total_results": 2,
			"total_pages": 1
		}`, showID, name))
	}))
	defer s.Close()

	tmdb := &episodic.TMDB{
		Client: s.Client(),
		Key:    "SUP",
		Base:   s.URL,
	}

	show, err := tmdb.SearchTV(name)

	if err != nil {
		t.Errorf("Unexpected error: %v", err)
	}
	if show.ID != showID {
		t.Fatalf("Show ID does not match, expected %v, got %v", showID, show.ID)
	}
	if show.Name != name {
		t.Fatalf("show name does not match, expected %v, got %v", showID, show.Name)
	}

}
