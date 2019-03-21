package main

// watchlist is used to serve data.WatchList to the frontend

import (
	"encoding/json"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	episodic "github.com/sethetter/episodic/pkg"
)

// TODO: Test this! It wouldn't be hard

// Response is the body of the response.
type Response struct {
	WatchList []episodic.Episode `json:"watch_list"`
}

// HandleRequest handles the lambda invocation.
func HandleRequest(req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	db, err := episodic.NewDataBucket(os.Getenv("DATA_BUCKET"), "data.json")
	if err != nil {
		return events.APIGatewayProxyResponse{StatusCode: 500}, err
	}

	data, err := db.Get()
	if err != nil {
		return events.APIGatewayProxyResponse{StatusCode: 500}, err
	}

	jsonStr, err := json.Marshal(&Response{WatchList: data.WatchList})
	if err != nil {
		return events.APIGatewayProxyResponse{StatusCode: 500}, err
	}

	return events.APIGatewayProxyResponse{
		StatusCode: 200,
		Headers: map[string]string{
			"content-type": "application/json",
		},
		Body: string(jsonStr),
	}, nil
}

func main() {
	lambda.Start(HandleRequest)
}
