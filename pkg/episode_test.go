package episodic_test

import (
	"testing"
	"time"

	episodic "github.com/sethetter/episodic/pkg"
)

func TestDaysFromAir(t *testing.T) {
	ct, _ := time.LoadLocation("America/Chicago")
	today := time.Date(2019, 1, 1, 0, 0, 0, 0, ct)

	tests := []struct {
		episode *episodic.Episode
		want    int
	}{
		{
			episode: &episodic.Episode{ID: 1, AirDate: "2019-01-02", Number: 1},
			want:    1,
		},
		{
			episode: &episodic.Episode{ID: 1, AirDate: "2019-01-03", Number: 1},
			want:    2,
		},
		{
			episode: &episodic.Episode{ID: 1, AirDate: "2019-01-08", Number: 1},
			want:    7,
		},
	}

	for _, tc := range tests {
		got, err := tc.episode.DaysFromAir(today)
		if err != nil {
			t.Errorf("unexpected error: %v", err)
		}
		if got != tc.want {
			t.Fatalf("got %d, want %d", got, tc.want)
		}
	}
}
