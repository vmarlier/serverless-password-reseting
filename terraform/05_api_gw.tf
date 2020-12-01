# New API gateway
resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.environment}-${var.application}-api_gateway"
  description = "This API will call 3 lambda function to interact with the DC and SNS"

  endpoint_configuration {
    types = ["PRIVATE"]
  }

  policy = <<EOF
{
  "Statement": [
    {
      "Principal": "*",
      "Action": "*",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# Resources
# We need 3 resources in this case:
# /ActiveDirectory/check
# /ActiveDirectory/change
# /sendCode
resource "aws_api_gateway_resource" "activeDirectory" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part   = "activeDirectory"
}

resource "aws_api_gateway_resource" "check" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id   = "${aws_api_gateway_resource.activeDirectory.id}"
  path_part   = "check"
}

resource "aws_api_gateway_resource" "change" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id   = "${aws_api_gateway_resource.activeDirectory.id}"
  path_part   = "change"
}

resource "aws_api_gateway_resource" "sendCode" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part   = "sendCode"
}


# Methods to be used on the above resources
# We have to create 3 GET methods on each resources (except on /activeDirectory which is a "root" resource)
resource "aws_api_gateway_method" "checkMethod" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.check.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "changeMethod" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.change.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "sendCode" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.sendCode.id}"
  http_method   = "POST"
  authorization = "NONE"
}

# Integration for each methods and define a Lambda Proxy Integration
resource "aws_api_gateway_integration" "integration-checkMethod" {
  rest_api_id             = "${aws_api_gateway_rest_api.api.id}"
  resource_id             = "${aws_api_gateway_resource.check.id}"
  http_method             = "${aws_api_gateway_method.checkMethod.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.checkAccount-lambda.arn}/invocations"
}

resource "aws_api_gateway_integration" "integration-changeMethod" {
  rest_api_id             = "${aws_api_gateway_rest_api.api.id}"
  resource_id             = "${aws_api_gateway_resource.change.id}"
  http_method             = "${aws_api_gateway_method.changeMethod.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.changePassword-lambda.arn}/invocations"
}
resource "aws_api_gateway_integration" "integration-sendCode" {
  rest_api_id             = "${aws_api_gateway_rest_api.api.id}"
  resource_id             = "${aws_api_gateway_resource.sendCode.id}"
  http_method             = "${aws_api_gateway_method.sendCode.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.sendCode-lambda.arn}/invocations"
}

# Method responses
# Create a 200 status code response for each method
resource "aws_api_gateway_method_response" "checkMethod-200" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.check.id}"
  http_method = "${aws_api_gateway_method.checkMethod.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method_response" "changeMethod-200" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.change.id}"
  http_method = "${aws_api_gateway_method.changeMethod.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method_response" "sendCode-200" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.sendCode.id}"
  http_method = "${aws_api_gateway_method.sendCode.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

/*
# Integration responses
# Work with Method responses
resource "aws_api_gateway_integration_response" "integration-resp-checkMethod" {
   rest_api_id = "${aws_api_gateway_rest_api.api.id}"
   resource_id = "${aws_api_gateway_resource.check.id}"
   http_method = "${aws_api_gateway_method.checkMethod.http_method}"
   status_code = "${aws_api_gateway_method_response.checkMethod-200.status_code}"

   response_templates = {
       "application/json" = ""
   } 
}

resource "aws_api_gateway_integration_response" "integration-resp-changeMethod" {
   rest_api_id = "${aws_api_gateway_rest_api.api.id}"
   resource_id = "${aws_api_gateway_resource.change.id}"
   http_method = "${aws_api_gateway_method.changeMethod.http_method}"
   status_code = "${aws_api_gateway_method_response.changeMethod-200.status_code}"

   response_templates = {
       "application/json" = ""
   } 
}

resource "aws_api_gateway_integration_response" "integration-resp-sendCode" {
   rest_api_id = "${aws_api_gateway_rest_api.api.id}"
   resource_id = "${aws_api_gateway_resource.sendCode.id}"
   http_method = "${aws_api_gateway_method.sendCode.http_method}"
   status_code = "${aws_api_gateway_method_response.sendCode-200.status_code}"

   response_templates = {
       "application/json" = ""
   } 
}
*/

# Create a new deployment
resource "aws_api_gateway_deployment" "deployment" {
  depends_on  = ["aws_api_gateway_integration.integration-checkMethod", "aws_api_gateway_integration.integration-changeMethod", "aws_api_gateway_integration.integration-sendCode"]
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "dev"
}

# Create a new stage
resource "aws_api_gateway_stage" "stage-dev" {
  stage_name    = "prod"
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  deployment_id = "${aws_api_gateway_deployment.deployment.id}"
}

# Settings for the new method
resource "aws_api_gateway_method_settings" "checkMethod-settings" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "${aws_api_gateway_stage.stage-dev.stage_name}"
  method_path = "${aws_api_gateway_resource.activeDirectory.path_part}/${aws_api_gateway_resource.check.path_part}/${aws_api_gateway_method.checkMethod.http_method}"

  settings {
    metrics_enabled = true
    logging_level   = "OFF"
  }
}

resource "aws_api_gateway_method_settings" "changeMethod-settings" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "${aws_api_gateway_stage.stage-dev.stage_name}"
  method_path = "${aws_api_gateway_resource.activeDirectory.path_part}/${aws_api_gateway_resource.change.path_part}/${aws_api_gateway_method.changeMethod.http_method}"

  settings {
    metrics_enabled = true
    logging_level   = "OFF"
  }
}

resource "aws_api_gateway_method_settings" "sendCode-settings" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "${aws_api_gateway_stage.stage-dev.stage_name}"
  method_path = "${aws_api_gateway_resource.sendCode.path_part}/${aws_api_gateway_method.sendCode.http_method}"

  settings {
    metrics_enabled = true
    logging_level   = "OFF"
  }
}
