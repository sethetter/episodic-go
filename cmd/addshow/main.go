package main

import (
	"flag"
	"fmt"
	"log"
	"os"

	episodic "github.com/sethetter/episodic/pkg"
)

var (
	query  = flag.String("query", "", "The search query")
	key    = flag.String("key", "", "TMDB API key")
	bucket = flag.String("bucket", "episodic-data", "S3 bucket holding data file")
)

func main() {
	flag.Parse()

	os.Setenv("AWS_SDK_LOAD_CONFIG", "true")

	show, err := searchShow()
	if err != nil {
		log.Fatalf("search failed: %v", err)
	}

	fmt.Printf("%s: %d\n", show.Name, show.ID)

	// TODO: Confirm selection

	_, err = addShow(show.ID)
	if err != nil {
		log.Fatalf("add show failed: %v", err)
	}

	fmt.Println("Show added!")
}

func addShow(id int) (episodic.Data, error) {
	db, err := episodic.NewDataBucket(*bucket, "data.json")
	if err != nil {
		log.Fatalf("initing data bucket failed: %v", err)
	}

	return db.AddShow(id)
}

func searchShow() (*episodic.TV, error) {
	tmdb := episodic.NewTMDBClient(*key)

	return tmdb.SearchTV(*query)
}
