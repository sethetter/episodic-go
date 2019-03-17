package main

import (
	"fmt"
	"os"
	"time"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	episodic "github.com/sethetter/episodic/pkg"
)

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
	db, err := episodic.NewDataBucket(os.Getenv("DATA_BUCKET"), "data.json")
	if err != nil {
		return events.APIGatewayProxyResponse{StatusCode: 500}, err
	}

	data, err := db.Get()
	if err != nil {
		return events.APIGatewayProxyResponse{StatusCode: 500}, err
	}

	if !numberAllowed(req, data.AllowedNumbers) {
		return events.APIGatewayProxyResponse{StatusCode: 301}, nil
	}

	tmdb := episodic.NewTMDBClient(os.Getenv("TMDB_API_KEY"))

	body := &Response{Shows: []show{}}

	for _, id := range data.ShowIDs {
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

func numberAllowed(req events.APIGatewayProxyRequest, allowed []string) bool {
	twilioReq, err := episodic.ParseTwilioRequest(req.Body)
	if err != nil {
		return false
	}

	found := false
	for _, n := range allowed {
		if n == twilioReq.From {
			found = true
		}
	}
	return found
}

func main() {
	lambda.Start(HandleRequest)
}
