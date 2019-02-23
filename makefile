build:
	go build -o ./bin/lambda ./cmd/lambda/main.go
	cd bin && zip lambda.zip lambda
