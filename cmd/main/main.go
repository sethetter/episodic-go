package main

import (
	"context"
	"fmt"
	"os"

	"github.com/aws/aws-lambda-go/lambda"
	episodic "github.com/sethetter/episodic/pkg"
)

// MyEvent is the expected structure of the input lambda event.
type MyEvent struct {
	Name string `json:"name"`
}

// HandleRequest handles the lambda invocation.
func HandleRequest(ctx context.Context, name MyEvent) (string, error) {
	tmdb := episodic.NewTMDBClient(os.Getenv("TMDB_API_KEY"))

	season, err := tmdb.MostRecentSeason(34307)
	if err != nil {
		return "", err
	}

	return fmt.Sprintf("%d", season), nil
}

func main() {
	lambda.Start(HandleRequest)
}
