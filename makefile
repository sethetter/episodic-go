build: twilio addshow

deps:
	go mod download

twilio:
	go build -o ./bin/twilio ./cmd/twilio/main.go
	cd bin && zip -o twilio.zip twilio

addshow:
	go build -o ./bin/addshow ./cmd/addshow/main.go

deploy:
	cd ops && terraform apply -var-file=secrets.tfvars

test:
	go test ./pkg
