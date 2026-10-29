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