package app

import (
	"github.com/spf13/viper"
)

const (
	envSlackIncomingWebhook = "SLACK_INCOMING_WEBHOOK"
)

// Conf -
// lambda environment varialbe
var Conf = &struct {
	SlackIncomingWebhook string
}{}

func init() {
	viper.AutomaticEnv()
	initConf()
}

func initConf() {
	Conf.SlackIncomingWebhook = viper.GetString(envSlackIncomingWebhook)
}
