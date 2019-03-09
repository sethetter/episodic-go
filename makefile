build: twilio

deps:
	go mod download

twilio:
	go build -o ./bin/twilio ./cmd/twilio/main.go
	cd bin && zip -o twilio.zip twilio

deploy:
	cd ops && terraform apply -var-file=secrets.tfvars

test:
	go test ./pkg
