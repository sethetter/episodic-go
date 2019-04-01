package main

// rmepisode is used to remove an episode from the watchlist

import (
	"encoding/json"
	"errors"
	"os"
	"sort"
	"strconv"

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
	// TODO: check for cookie

	db, err := episodic.NewDataBucket(os.Getenv("DATA_BUCKET"), "data.json")
	if err != nil {
		return events.APIGatewayProxyResponse{StatusCode: 500}, err
	}

	data, err := db.Get()
	if err != nil {
		return events.APIGatewayProxyResponse{StatusCode: 500}, err
	}

	idStr, ok := req.QueryStringParameters["id"]
	if !ok {
		return events.APIGatewayProxyResponse{StatusCode: 500}, errors.New("no id param found in query string")
	}

	id, err := strconv.Atoi(idStr)
	if err != nil {
		return events.APIGatewayProxyResponse{StatusCode: 500}, err
	}

	if data, err = db.RemoveEpisode(id); err != nil {
		return events.APIGatewayProxyResponse{StatusCode: 500}, err
	}

	sort.Sort(episodic.ByAirDate(data.WatchList))

	jsonStr, err := json.Marshal(&Response{WatchList: data.WatchList})
	if err != nil {
		return events.APIGatewayProxyResponse{StatusCode: 500}, err
	}

	return events.APIGatewayProxyResponse{
		StatusCode: 200,
		Headers: map[string]string{
			"content-type":                "application/json",
			"access-control-allow-origin": "*",
		},
		Body: string(jsonStr),
	}, nil
}

func main() {
	lambda.Start(HandleRequest)
}
