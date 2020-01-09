package app

import (
	"bytes"
	"context"
	"fmt"
	"io/ioutil"
	"net/http"

	"github.com/aws/aws-lambda-go/events"
)

// HandleRequest -
func HandleRequest(ctx context.Context, event events.SNSEvent) (string, error) {
	fmt.Println(event)
	for _, record := range event.Records {
		webhook := Conf.SlackIncomingWebhook
		// Override webhook with MessageAttributes["SlackIncomingWebhook"]
		webhookAttr := record.SNS.MessageAttributes["SlackIncomingWebhook"]
		if webhookAttr != nil {
			attr, ok := webhookAttr.(map[string]interface{})
			if ok {
				webhook = attr["Value"].(string)
			}
		}
		resp, err := PostMessage(http.DefaultClient, webhook, []byte(record.SNS.Message))
		if err != nil {
			return "", err
		}
		fmt.Println(string(resp))
	}

	return "succeed", nil
}

// HTTPClient is a client with Do method to send out a request
type HTTPClient interface {
	Do(req *http.Request) (*http.Response, error)
}

// PostMessage posts a json format message to webhook
var PostMessage = func(client HTTPClient, webhook string, message []byte) ([]byte, error) {
	// Send
	request, err := http.NewRequest(http.MethodPost, webhook, bytes.NewBuffer(message))
	if err != nil {
		return nil, err
	}
	// Header
	request.Header.Set("Content-Type", "application/json")

	resp, err := client.Do(request)
	if err != nil {
		return nil, err
	}

	defer resp.Body.Close()
	body, _ := ioutil.ReadAll(resp.Body)
	return body, nil
}
