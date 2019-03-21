DEPLOYED_AT:=$$(date +%s)
WEB_BUCKET:=$$(cd ops && terraform output web_bucket)

build: twilio addshow loadeps watchlist web

deps:
	go mod download

twilio:
	go build -o ./bin/twilio ./lambda/twilio/main.go
	cd bin && zip -o twilio.zip twilio

addshow:
	go build -o ./bin/addshow ./cmd/addshow/main.go

loadeps:
	go build -o ./bin/loadeps ./lambda/loadeps/main.go
	cd bin && zip -o loadeps.zip loadeps

watchlist:
	go build -o ./bin/watchlist ./lambda/watchlist/main.go
	cd bin && zip -o watchlist.zip watchlist

web:
	npm run build

# TODO
# watch:
#   modd && npm run watch && npm run serve

deploy:
	cd ops && TF_VAR_deployed_at=${DEPLOYED_AT} terraform apply -var-file=secrets.tfvars
	aws s3 sync .web-build s3://${WEB_BUCKET}

test:
	go test ./pkg
