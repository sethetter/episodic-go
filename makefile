build: twilio addshow

deps:
	go mod download

twilio:
	go build -o ./bin/twilio ./lambda/twilio/main.go
	cd bin && zip -o twilio.zip twilio

addshow:
	go build -o ./bin/addshow ./cmd/addshow/main.go

web:
	npm run build

# TODO
# watch:
#   modd && npm run watch && npm run serve

deploy:
	cd ops && terraform apply -var-file=secrets.tfvars

test:
	go test ./pkg
