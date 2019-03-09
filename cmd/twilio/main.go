package main

import (
	"fmt"
	"os"
	"time"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	episodic "github.com/sethetter/episodic/pkg"
)

var showIDs = []int{
	34307, // Shameless
	1399,  // Game of Thrones
	63247, // Westworld
	68898, // Crashing
}

// Response is the body of the response.
type Response struct {
	Shows []show `json:"shows"`
}

// Render takes response data and outputs it in a structured format.
func (r *Response) Render() string {
	out := `<?xml version="1.0" encoding="UTF-8"?><Response><Message>`
	for _, s := range r.Shows {
		out += fmt.Sprintf("%s: %d\n", s.Name, s.DaysAway)
	}
	return out + "</Message></Response>"
}

type show struct {
	Name     string `json:"name"`
	DaysAway int    `json:"daysAway"`
}

// HandleRequest handles the lambda invocation.
func HandleRequest(req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	tmdb := episodic.NewTMDBClient(os.Getenv("TMDB_API_KEY"))

	body := &Response{Shows: []show{}}

	data, err := episodic.NewDataBucket(os.Getenv("DATA_BUCKET"), "data.json")
	if err != nil {
		return events.APIGatewayProxyResponse{StatusCode: 500}, err
	}

	showIDs, err := data.ShowIDs()
	if err != nil {
		return events.APIGatewayProxyResponse{StatusCode: 500}, err
	}

	for _, id := range showIDs {
		s, err := tmdb.GetTV(id)
		if err != nil {
			return events.APIGatewayProxyResponse{StatusCode: 500}, err
		}

		if s.HasNextEpisode() {
			daysTilNextEp, err := s.NextEpisode.DaysFromAir(time.Now())
			if err != nil {
				return events.APIGatewayProxyResponse{StatusCode: 500}, err
			}

			body.Shows = append(body.Shows, show{s.Name, daysTilNextEp})
		}
	}

	return events.APIGatewayProxyResponse{
		StatusCode: 200,
		Headers: map[string]string{
			"content-type": "text/xml",
		},
		Body: body.Render(),
	}, nil
}

func main() {
	lambda.Start(HandleRequest)
}
