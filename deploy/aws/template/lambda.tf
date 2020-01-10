data "aws_iam_policy_document" "lambda-policy" {
  statement {
    sid    = ""
    effect = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam-for-lambda" {
  name               = "iam-for-lambda"
  assume_role_policy = "${data.aws_iam_policy_document.lambda-policy.json}"
}

resource "aws_lambda_function" "slack-notification-worker" {
  function_name = "slack-notification-worker-{{.Env.DEPLOY_ENV}}"
  description = "send message to slack"

  s3_bucket = "willis-lambda-assets"
  s3_key = "{{.Env.VERSION}}/slack-notification-worker.zip"

  role    = "${aws_iam_role.iam-for-lambda.arn}"
  handler = "slack-notification-worker"
  runtime = "go1.x"
  timeout = 30

  environment {
    variables = {
      SLACK_INCOMING_WEBHOOK = "{{.Env.SLACK_INCOMING_WEBHOOK}}"
    }
  }
}
