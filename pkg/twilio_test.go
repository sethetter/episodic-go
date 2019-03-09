package episodic_test

import (
	"testing"

	episodic "github.com/sethetter/episodic/pkg"
)

func TestParseTwilioRequest(t *testing.T) {
	tests := []struct {
		desc string
		in   string
		want episodic.TwilioRequest
		err  bool
	}{
		{
			"Valid twilio request input",
			"ToCountry=US&ToState=KS&SmsMessageSid=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx&NumMedia=0&ToCity=DOUGLASS&FromZip=67212&SmsSid=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx&FromState=KS&SmsStatus=received&FromCity=WICHITA&Body=Sup&FromCountry=US&To=%2B13169999999&ToZip=67039&NumSegments=1&MessageSid=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx&AccountSid=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx&From=%2B13169999998&ApiVersion=2010-04-01",
			episodic.TwilioRequest{From: "+13169999998", Body: "Sup"},
			false,
		},
		{
			"Invalid twilio request input",
			"Something=What&Dude=Freal",
			episodic.TwilioRequest{},
			true,
		},
	}

	for _, tc := range tests {
		r, err := episodic.ParseTwilioRequest(tc.in)
		if err != nil && !tc.err {
			t.Fatalf("unexpected error: %v", err)
		}
		if err == nil && tc.err {
			t.Fatal("expected error, but did not see one")
		}
		if r.Body != tc.want.Body {
			t.Fatalf("invalid body, got %v, want %v", r.Body, tc.want.Body)
		}
		if r.From != tc.want.From {
			t.Fatalf("invalid from, got %v, want %v", r.From, tc.want.From)
		}
	}
}
