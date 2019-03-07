build: listshows

listshows:
	go build -o ./bin/lambda ./cmd/lambda/main.go
	cd bin && zip lambda.zip lambda

deploy:
	cd ops && terraform apply -var-file=secrets.tfvars

test:
	go test ./pkg
