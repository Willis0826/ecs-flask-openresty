# Slack Notification Worker

## Usage

Consumes the SNS `slack-notification`. The lambda gets the `SLACK_INCOMING_WEBHOOK` from environment variables or SNS MessageAttributes.
(The SNS MessageAttributes will override the environment variables)

MessageAttributes with field `SlackIncomingWebhook` to override incoming webhook

```json
{
    "SlackIncomingWebhook": {
        "Type": "String",
        "Value": "https://hooks.slack.com/services/xxxxxxxxx/0000000000/xxxxxxxxxxxxxxxxxx"
    }
}
```

## Environment Variables

`SLACK_INCOMING_WEBHOOK` The URL which message body sent to.
