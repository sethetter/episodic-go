package main

// loadeps runs on a daily basis and populates the data.WatchList

import (
	"fmt"
	"os"

	"github.com/aws/aws-lambda-go/lambda"
	episodic "github.com/sethetter/episodic/pkg"
)

// HandleRequest handles the lambda invocation.
func HandleRequest() (string, error) {
	db, err := episodic.NewDataBucket(os.Getenv("DATA_BUCKET"), "data.json")
	if err != nil {
		return "", fmt.Errorf("failed getting data bucket: %v", err)
	}

	data, err := db.Get()
	if err != nil {
		return "", fmt.Errorf("failed loading data from bucket: %v", err)
	}

	tmdb := episodic.NewTMDBClient(os.Getenv("TMDB_API_KEY"))

	for _, id := range data.ShowIDs {
		s, err := tmdb.GetTV(id)
		if err != nil {
			return "", fmt.Errorf("failed to get show id %d: %v", id, err)
		}

		if s.HasNextEpisode() {
			_, err := db.AddEpisode(*s.NextEpisode)
			if err != nil {
				return "", fmt.Errorf("failed to save to watch list show: %d, err: %v", id, err)
			}
		}
	}

	return "done", nil
}

func main() {
	lambda.Start(HandleRequest)
}
