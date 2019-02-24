package main

import (
	"context"
	"os"

	"github.com/aws/aws-lambda-go/lambda"
	tmdb "github.com/ryanbradynd05/go-tmdb"
)

// MyEvent is the expected structure of the input lambda event.
type MyEvent struct {
	Name string `json:"name"`
}

// HandleRequest handles the lambda invocation.
func HandleRequest(ctx context.Context, name MyEvent) (string, error) {
	config := tmdb.Config{
		APIKey:   os.Getenv("TMDB_API_KEY"),
		Proxies:  nil,
		UseProxy: false,
	}
	tmdbAPI := tmdb.Init(config)

	shameless, err := tmdbAPI.GetTvInfo(34307, nil)
	if err != nil {
		return "Error!", err
	}

	shamelessJSON, err := tmdb.ToJSON(shameless)
	if err != nil {
		return "Error!", err
	}

	return shamelessJSON, nil
}

func main() {
	lambda.Start(HandleRequest)
}
