package episodic

import (
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
	ShowIDs []int `json:"show_ids"`
}

// NewDataBucket takes config and returns a new instance of the data bucket
func NewDataBucket(bucket, file string) (*DataBucket, error) {
	dataBucket := &DataBucket{
		bucket: bucket,
		file:   file,
	}

	// TODO: aws credentials?
	sess, err := session.NewSession()
	if err != nil {
		return dataBucket, err
	}

	dataBucket.sess = sess

	return dataBucket, nil
}

// ShowIDs returns the list of Show IDs from the data bucket
func (db *DataBucket) ShowIDs() ([]int, error) {
	downloader := s3manager.NewDownloader(db.sess)

	getObjInput := &s3.GetObjectInput{
		Bucket: aws.String(db.bucket),
		Key:    aws.String(db.file),
	}

	buf := aws.NewWriteAtBuffer([]byte{})

	if _, err := downloader.Download(buf, getObjInput); err != nil {
		return []int{}, err
	}

	var data Data
	if err := json.Unmarshal(buf.Bytes(), &data); err != nil {
		return []int{}, err
	}

	return data.ShowIDs, nil
}
