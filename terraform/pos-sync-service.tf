# pos-sync-service รันบน Lambda + Function URL แยกเดี่ยว ไม่ผ่าน CloudFront ของ portal
# Terraform สร้าง function ด้วยโค้ด placeholder ครั้งแรก ส่วนโค้ดจริง Jenkins (pipelines/pos-center) อัปด้วย update-function-code
# ใช้ lambda_assume_role / local.tags ร่วมกับ portal-service (main.tf)

locals {
  pos_sync_service_function_name = "pos-sync-service"
}

resource "aws_iam_role" "pos_sync_service" {
  name               = "${local.pos_sync_service_function_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "pos_sync_service_logs" {
  role       = aws_iam_role.pos_sync_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "pos_sync_service" {
  name              = "/aws/lambda/${local.pos_sync_service_function_name}"
  retention_in_days = 14
  tags              = local.tags
}

data "archive_file" "pos_sync_service_placeholder" {
  type        = "zip"
  output_path = "${path.module}/.build/pos-sync-service-placeholder.zip"

  source {
    filename = "index.js"
    content  = <<-EOT
      exports.handler = async () => ({
        statusCode: 503,
        body: "pos-sync-service not deployed yet",
      });
    EOT
  }
}

resource "aws_lambda_function" "pos_sync_service" {
  function_name = local.pos_sync_service_function_name
  role          = aws_iam_role.pos_sync_service.arn
  filename      = data.archive_file.pos_sync_service_placeholder.output_path
  handler       = "index.handler"
  runtime       = "nodejs22.x"
  architectures = ["x86_64"]
  memory_size   = 256
  timeout       = 15

  environment {
    variables = {
      NODE_ENV        = "development"
      DATABASE_URL    = var.pos_sync_service_database_url
      SYNC_JWT_SECRET = var.pos_sync_service_jwt_secret
      ORIGIN_SECRET   = var.pos_sync_service_origin_secret
    }
  }

  # โค้ดถูก Jenkins อัปทับ ไม่ให้ terraform apply ย้อนกลับไปเป็น placeholder
  lifecycle {
    ignore_changes = [filename, source_code_hash, code_sha256]
  }

  tags = local.tags

  depends_on = [
    aws_iam_role_policy_attachment.pos_sync_service_logs,
    aws_cloudwatch_log_group.pos_sync_service,
  ]
}

# Function URL เปิด public ให้ client เรียกตรง แต่ app ปฏิเสธ request ที่ไม่มี header x-origin-secret
resource "aws_lambda_function_url" "pos_sync_service" {
  function_name      = aws_lambda_function.pos_sync_service.function_name
  authorization_type = "NONE"
}

resource "aws_lambda_permission" "pos_sync_service_url_invoke" {
  statement_id             = "FunctionURLAllowInvokeAction"
  action                   = "lambda:InvokeFunction"
  function_name            = aws_lambda_function.pos_sync_service.function_name
  principal                = "*"
  invoked_via_function_url = true
}
