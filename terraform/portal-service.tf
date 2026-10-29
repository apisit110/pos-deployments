# portal-service (express ผ่าน serverless-http) รันบน Lambda + Function URL แล้วให้ CloudFront เรียกผ่าน /api/*
# Terraform สร้าง function ด้วยโค้ด placeholder ครั้งแรก ส่วนโค้ดจริง Jenkins (pipelines/pos-center) อัปด้วย update-function-code

locals {
  portal_service_function_name = "portal-service"
}

resource "aws_iam_role" "portal_service" {
  name               = "${local.portal_service_function_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = local.tags
}

# ให้เขียน log ลง CloudWatch ได้
resource "aws_iam_role_policy_attachment" "portal_service_logs" {
  role       = aws_iam_role.portal_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "portal_service" {
  name              = "/aws/lambda/${local.portal_service_function_name}"
  retention_in_days = 14
  tags              = local.tags
}

# โค้ด placeholder ใช้แค่ตอนสร้าง function ครั้งแรก
data "archive_file" "portal_service_placeholder" {
  type        = "zip"
  output_path = "${path.module}/.build/portal-service-placeholder.zip"

  source {
    filename = "index.js"
    content  = <<-EOT
      exports.handler = async () => ({
        statusCode: 503,
        body: "portal-service not deployed yet",
      });
    EOT
  }
}

resource "aws_lambda_function" "portal_service" {
  function_name = local.portal_service_function_name
  role          = aws_iam_role.portal_service.arn
  filename      = data.archive_file.portal_service_placeholder.output_path
  handler       = "index.handler"
  runtime       = "nodejs22.x" # ตรงกับ esbuild --target=node22 ใน build:lambda
  architectures = ["x86_64"]
  memory_size   = 256
  timeout       = 15

  environment {
    variables = {
      NODE_ENV      = "development"
      DATABASE_URL  = var.portal_service_database_url
      JWT_SECRET    = var.portal_service_jwt_secret
      ORIGIN_SECRET = var.origin_secret
      PORTAL_ORIGIN = var.portal_origin
    }
  }

  # โค้ดถูก Jenkins อัปทับ ไม่ให้ terraform apply ย้อนกลับไปเป็น placeholder
  lifecycle {
    ignore_changes = [filename, source_code_hash, code_sha256]
  }

  tags = local.tags

  depends_on = [
    aws_iam_role_policy_attachment.portal_service_logs,
    aws_cloudwatch_log_group.portal_service,
  ]
}

# Function URL เปิด public แต่ app ปฏิเสธ request ที่ไม่มี header x-origin-secret (CloudFront เป็นคนใส่)
resource "aws_lambda_function_url" "portal_service" {
  function_name      = aws_lambda_function.portal_service.function_name
  authorization_type = "NONE"
}

# Function URL ที่สร้างใหม่ต้องมี lambda:InvokeFunction คู่กับ lambda:InvokeFunctionUrl (ที่ resource ข้างบนเพิ่มให้)
resource "aws_lambda_permission" "portal_service_url_invoke" {
  statement_id             = "FunctionURLAllowInvokeAction"
  action                   = "lambda:InvokeFunction"
  function_name            = aws_lambda_function.portal_service.function_name
  principal                = "*"
  invoked_via_function_url = true
}
