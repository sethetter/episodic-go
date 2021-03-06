package episodic

import (
	"strings"
	"time"
)

// Episode represents a TV Episode object from TMDB.
type Episode struct {
	ID       int    `json:"id"`
	ShowName string `json:"show_name"`
	AirDate  string `json:"air_date"`
	Number   int    `json:"episode_number"`
	Season   int    `json:"season_number"`
}

// DaysFromAir returns the number of days from the AirDate.
func (e *Episode) DaysFromAir(now time.Time) (int, error) {
	t, err := time.Parse("2006-01-02", e.AirDate)
	if err != nil {
		return 0, err
	}

	return (t.YearDay() - now.YearDay()), nil
}

// ByAirDate implements sort.Interface for Episode.
type ByAirDate []Episode

func (b ByAirDate) Len() int           { return len(b) }
func (b ByAirDate) Swap(i, j int)      { b[i], b[j] = b[j], b[i] }
func (b ByAirDate) Less(i, j int) bool { return strings.Compare(b[i].AirDate, b[j].AirDate) < 0 }
