package episodic

import (
	"errors"
	"net/url"
)

// TwilioRequest represents the request body incoming from Twilio
type TwilioRequest struct {
	From string
	Body string
}

// ParseTwilioRequest takes a urlencoded request body and turns it into
// a TwilioRequest struct.
func ParseTwilioRequest(body string) (TwilioRequest, error) {
	vals, err := url.ParseQuery(body)
	if err != nil {
		return TwilioRequest{}, err
	}

	if !validateTwilioRequest(vals) {
		return TwilioRequest{}, errors.New("invalid twilio request")
	}

	return TwilioRequest{
		From: vals.Get("From"),
		Body: vals.Get("Body"),
	}, nil
}

func validateTwilioRequest(vals url.Values) bool {
	if vals.Get("From") == "" {
		return false
	}
	if vals.Get("Body") == "" {
		return false
	}
	return true
}
