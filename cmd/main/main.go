package main

import (
	"context"
	"fmt"
	"os"
	"time"

	"github.com/aws/aws-lambda-go/lambda"
	episodic "github.com/sethetter/episodic/pkg"
)

var showIDs = []int{
	34307, // Shameless
	1399,  // Game of Thrones
	63247, // Westworld
}

type response struct {
	shows []show
}

func (r *response) render() string {
	out := ""
	for _, s := range r.shows {
		out += fmt.Sprintf("%s: %d\n", s.name, s.daysAway)
	}
	return out
}

type show struct {
	name     string
	daysAway int
}

// HandleRequest handles the lambda invocation.
func HandleRequest(ctx context.Context, event interface{}) (string, error) {
	tmdb := episodic.NewTMDBClient(os.Getenv("TMDB_API_KEY"))

	resp := &response{shows: []show{}}

	for _, id := range showIDs {
		s, err := tmdb.GetTV(id)
		if err != nil {
			return "", err
		}

		if s.HasNextEpisode() {
			daysTilNextEp, err := s.NextEpisode.DaysFromAir(time.Now())
			if err != nil {
				return "", err
			}

			resp.shows = append(resp.shows, show{s.Name, daysTilNextEp})
		}
	}

	return resp.render(), nil
}

func main() {
	lambda.Start(HandleRequest)
}
