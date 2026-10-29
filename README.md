```bash
docker compose up -d
# ดูรหัสผ่านสำหรับ unlock ตอนเข้าครั้งแรก
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

ต้องติดตั้ง plugin

[] Git Parameter ใช้สำหรับ checkout และเลือก branch ใน pipeline
[] Role-Based Authorization Strategy ใช้กำหนดสิทธิ์ เพิ่มลบ credential ของ View/Project ตัวเอง
- กำหนด Manage Jenkins ใน Security เลือก Authorization เป็น Role-Based Strategy
- manage
  - สร้าง user
  - สร้าง role
    - global role กำหนด
      - Overall เป็น Read ให้เห็น jenkins dashboard
      - Job เป็น Read ให้เห็น jobs/project/pipeline
    - item role กำหนด regex ตามชื่อ folder
  - assign role
    - global role
    - item role
[] AWS Credentials สร้าง credential ชนิด AWS ชื่อ aws-credentials
- สร้าง IAM user เพราะจะใช้ AWS_ACCESS_KEY_ID กับ AWS_SECRET_ACCESS_KEY ไม่ใช้รวมกับ terraform
- กำหนด policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ListBucket",
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::lab-pos-cashier-center"
    },
    {
      "Sid": "WriteObjects",
      "Effect": "Allow",
      "Action": ["s3:PutObject", "s3:DeleteObject"],
      "Resource": "arn:aws:s3:::lab-pos-cashier-center/*"
    },
    {
      "Sid": "InvalidateCache",
      "Effect": "Allow",
      "Action": "cloudfront:CreateInvalidation",
      "Resource": "arn:aws:cloudfront::<ACCOUNT_ID>:distribution/<DISTRIBUTION_ID>"
    }
  ]
}

```
- Add Credentials ใน folder หรือ config manage jenkins
  - Kind: AWS Credentials
  - ID: aws-credentials ต้องตรงกับใน Jenkinsfile
  - Access Key ID และ Secret Access Key

เขียน groovy pipeline

สร้าง folder

- กำหนด credential ของ folder
  - ใน pipeline ใช้คำสั่ง withCredentials ต้องกำหนดเป็นแบบ secret txt
    - และ secret คือ ghp_xxx_github_secret 
    - โดย credentialsId คือ github-packages-token

สร้าง pipeline

ทดสอบรัน
