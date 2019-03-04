package main

import (
	"context"
	"fmt"
	"os"
	"time"

	"github.com/aws/aws-lambda-go/lambda"
	episodic "github.com/sethetter/episodic/pkg"
)

var shamelessID = 34307

// MyEvent is the expected structure of the input lambda event.
type MyEvent struct {
	Name string `json:"name"`
}

// HandleRequest handles the lambda invocation.
func HandleRequest(ctx context.Context, name MyEvent) (string, error) {
	tmdb := episodic.NewTMDBClient(os.Getenv("TMDB_API_KEY"))

	show, err := tmdb.GetTV(shamelessID)
	if err != nil {
		return "", err
	}

	daysTilNextEp, err := show.NextEpisode.DaysFromAir(time.Now())
	if err != nil {
		return "", err
	}

	return fmt.Sprintf("Days until next Shameless episode: %d", daysTilNextEp), nil
}

func main() {
	lambda.Start(HandleRequest)
}
