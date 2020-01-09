package main

import (
	"github.com/Willis0826/ecs-flask-openresty/slack-notification-worker/app"

	"github.com/aws/aws-lambda-go/lambda"
)

var (
	version = "unknown-dev"
)

func main() {
	lambda.Start(app.HandleRequest)
}
