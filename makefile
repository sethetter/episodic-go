DEPLOYED_AT:=$$(date +%s)
WEB_BUCKET:=$$(cd ops && terraform output web_bucket)

build: twilio addshow loadeps watchlist rmepisode web

deps:
	go mod download

addshow:
	go build -o ./bin/addshow ./cmd/addshow/main.go

twilio:
	GOOS=linux go build -o ./bin/twilio ./lambda/twilio/main.go
	cd bin && zip -o twilio.zip twilio

loadeps:
	GOOS=linux go build -o ./bin/loadeps ./lambda/loadeps/main.go
	cd bin && zip -o loadeps.zip loadeps

watchlist:
	GOOS=linux go build -o ./bin/watchlist ./lambda/watchlist/main.go
	cd bin && zip -o watchlist.zip watchlist

rmepisode:
	GOOS=linux go build -o ./bin/rmepisode ./lambda/rmepisode/main.go
	cd bin && zip -o rmepisode.zip rmepisode

web:
	npm run build

# TODO
# watch:
#   modd && npm run watch && npm run serve

deploy: deploy-server deploy-web

deploy-server:
	cd ops && TF_VAR_deployed_at=${DEPLOYED_AT} terraform apply -var-file=secrets.tfvars

deploy-web:
	aws s3 sync .web-build s3://${WEB_BUCKET}

test:
	go test ./pkg

data-pull:
	aws s3 cp s3://episodic-data/data.json data.json

data-push:
	aws s3 cp data.json s3://episodic-data/data.json
