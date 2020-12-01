all: rm

rm: zip
	rm -f website

zip: build
	zip ../../terraform/website.zip -r ../../website

build:
	GOARCH=amd64 GOOS=linux go build -o website main.go
