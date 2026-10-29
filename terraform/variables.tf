variable "environment" {
  type        = string
  description = "ชื่อสภาพแวดล้อมระบบ"
  default     = "Dev"
}

variable "project" {
  type        = string
  description = "ชื่อโครงการ"
  default     = "POS_CENTER"
}

variable "team" {
  type        = string
  description = "ชื่อทีม"
  default     = "Lab"
}

variable "bucket_name" {
  type        = string
  description = "ชื่อ bucket ที่ใช้เก็บไฟล์ web"
  default     = "lab-pos-cashier-center"
}

# ---------- portal-service (Lambda) ----------
# ค่าลับให้ใส่ใน terraform.tfvars (ถูก .gitignore ไว้แล้ว)

variable "portal_service_database_url" {
  type        = string
  description = "connection string ของ database ที่ portal-service ใช้"
  sensitive   = true
}

variable "portal_service_jwt_secret" {
  type        = string
  description = "secret สำหรับ sign JWT ของ portal-service"
  sensitive   = true
}

variable "origin_secret" {
  type        = string
  description = "ค่า header x-origin-secret ที่ CloudFront ส่งไป Lambda (app ปฏิเสธ request ที่ไม่มี)"
  sensitive   = true
}

variable "portal_origin" {
  type        = string
  description = "origin ของหน้าเว็บ portal สำหรับ CORS เช่น https://xxxx.cloudfront.net"
}

# ---------- pos-sync-service (Lambda) ----------

variable "pos_sync_service_database_url" {
  type        = string
  description = "connection string ของ database ที่ pos-sync-service ใช้"
  sensitive   = true
}

variable "pos_sync_service_jwt_secret" {
  type        = string
  description = "SYNC_JWT_SECRET ของ pos-sync-service"
  sensitive   = true
}

variable "pos_sync_service_origin_secret" {
  type        = string
  description = "ค่า header x-origin-secret ที่ client ต้องส่งมาเมื่อเรียก Function URL ของ pos-sync-service (แยกจาก origin_secret ของ CloudFront)"
  sensitive   = true
}
