package episodic

import (
	"bytes"
	"encoding/json"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/aws/aws-sdk-go/service/s3/s3manager"
)

var dataFileName = "data.json"

// DataBucket controls access to the data storage S3 bucket
type DataBucket struct {
	bucket string
	file   string
	sess   *session.Session
}

// Data represents the JSON structure of the data held in S3
type Data struct {
	ShowIDs        []int     `json:"show_ids"`
	AllowedNumbers []string  `json:"allowed_numbers"`
	WatchList      []Episode `json:"watch_list"`
}

// NewDataBucket takes config and returns a new instance of the data bucket
func NewDataBucket(bucket, file string) (*DataBucket, error) {
	dataBucket := &DataBucket{
		bucket: bucket,
		file:   file,
	}

	// Loads creds from env vars, I think
	sess, err := session.NewSession()
	if err != nil {
		return dataBucket, err
	}

	dataBucket.sess = sess

	return dataBucket, nil
}

// Get pulls the data from S3 and returns it
func (db *DataBucket) Get() (Data, error) {
	downloader := s3manager.NewDownloader(db.sess)

	getObjInput := &s3.GetObjectInput{
		Bucket: aws.String(db.bucket),
		Key:    aws.String(db.file),
	}

	buf := aws.NewWriteAtBuffer([]byte{})
	var data Data

	if _, err := downloader.Download(buf, getObjInput); err != nil {
		return data, err
	}

	if err := json.Unmarshal(buf.Bytes(), &data); err != nil {
		return data, err
	}

	return data, nil
}

func (db *DataBucket) save(data Data) (Data, error) {
	uploader := s3manager.NewUploader(db.sess)

	newJSON, err := json.Marshal(data)
	if err != nil {
		return data, err
	}

	uploadInput := &s3manager.UploadInput{
		Bucket: aws.String(db.bucket),
		Key:    aws.String(db.file),
		Body:   bytes.NewReader(newJSON),
	}

	if _, err := uploader.Upload(uploadInput); err != nil {
		return data, err
	}

	return data, nil
}

// AddShow saves a show ID to the data file
func (db *DataBucket) AddShow(showID int) (Data, error) {
	data, err := db.Get()
	if err != nil {
		return data, err
	}

	found := false
	for _, id := range data.ShowIDs {
		if id == showID {
			found = true
		}
	}

	if !found {
		data.ShowIDs = append(data.ShowIDs, showID)
		return db.save(data)
	}

	return data, nil
}

// TODO: Generalize the find no dup and save functionality, with a comparator func
// AddEpisode adds episode data to the data bucket,
func (db *DataBucket) AddEpisode(ep Episode) (Data, error) {
	data, err := db.Get()
	if err != nil {
		return data, err
	}

	found := false
	for _, epp := range data.WatchList {
		if epp.ID == ep.ID {
			found = true
		}
	}

	if !found {
		data.WatchList = append(data.WatchList, ep)
		return db.save(data)
	}

	return data, nil
}
