# Create new lambdas
# There are 3 lambda needed:
#  - checkAccount
#  - sendCode
#  - changePassword
resource "aws_lambda_function" "sendCode-lambda" {
    filename = "${var.lambda-filenames["sendCode"]}"
    function_name = "${var.environment}-${var.application}-sendCode"
    role = "${aws_iam_role.role-lambda-sendCode.arn}"
    handler = "main"
    source_code_hash = "$(filebase64sha256(${var.lambda-filenames["sendCode"]}))"
    runtime = "go1.x"
    
    ## environment variable need to be set manually
    environment {
        variables = {
            CLIENTID = ""
            CLIENTSECRET = ""
            PASSWORD = ""
            SECURITYTOKEN = ""
            USERNAME = ""
        }
    }
}

resource "aws_lambda_function" "checkAccount-lambda" {
    filename = "${var.lambda-filenames["checkAccount"]}"
    function_name = "${var.environment}-${var.application}-checkAccount"
    role = "${aws_iam_role.role-lambda-checkAccount.arn}"
    handler = "main"
    source_code_hash = "$(filebase64sha256(${var.lambda-filenames["checkAccount"]}))"
    runtime = "go1.x"

    ## environment variable need to be set manually
    environment {
        variables = {
            ADMIN = ""
            ADMINPASS = ""
            AD = ""
            ADP = ""
        }
    }
}

resource "aws_lambda_function" "changePassword-lambda" {
    filename = "${var.lambda-filenames["changePassword"]}"
    function_name = "${var.environment}-${var.application}-changePassword"
    role = "${aws_iam_role.role-lambda-changePassword.arn}"
    handler = "main"
    source_code_hash = "$(filebase64sha256(${var.lambda-filenames["changePassword"]}))"
    runtime = "go1.x"

    ## environment variable need to be set manually
    environment {
        variables = {
            ADMIN = ""
            ADMINPASS = ""
            AD = ""
            ADP = ""
        }
    }
}


### Lambda permissions to fix error on testing the lambda proxy from the api_gateway_integration
resource "aws_lambda_permission" "apigw-checkMethod-lambda" {
    statement_id  = "AllowCheckMethodExecutionFromAPIGateway"
    action        = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.checkAccount-lambda.function_name}"
    principal     = "apigateway.amazonaws.com"

    source_arn = "arn:aws:execute-api:${var.region}:${var.accountId}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.checkMethod.http_method}/${aws_api_gateway_resource.activeDirectory.path_part}/${aws_api_gateway_resource.check.path_part}"
}

resource "aws_lambda_permission" "apigw-changeMethod-lambda" {
    statement_id  = "AllowChangeMethodExecutionFromAPIGateway"
    action        = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.changePassword-lambda.function_name}"
    principal     = "apigateway.amazonaws.com"

    source_arn = "arn:aws:execute-api:${var.region}:${var.accountId}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.changeMethod.http_method}/${aws_api_gateway_resource.activeDirectory.path_part}/${aws_api_gateway_resource.change.path_part}"
}

resource "aws_lambda_permission" "apigw-sendCode-lambda" {
    statement_id  = "AllowSendCodeExecutionFromAPIGateway"
    action        = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.sendCode-lambda.function_name}"
    principal     = "apigateway.amazonaws.com"

    source_arn = "arn:aws:execute-api:${var.region}:${var.accountId}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.sendCode.http_method}/${aws_api_gateway_resource.sendCode.path_part}"
}
