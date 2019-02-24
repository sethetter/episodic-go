build:
	go build -o ./bin/main ./cmd/main/main.go
	cd bin && zip main.zip main

deploy:
	cd ops && terraform apply -var-file=secrets.tfvars
