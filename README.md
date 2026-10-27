```bash
docker compose up -d
# ดูรหัสผ่านสำหรับ unlock ตอนเข้าครั้งแรก
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

ต้องติดตั้ง plugin

[] Git Parameter ใช้สำหรับ checkout และเลือก branch ใน pipeline
[] Role-Based Authorization Strategy ใช้กำหนดสิทธิ์ เพิ่มลบ credential ของ View/Project ตัวเอง
manage
- สร้าง user
- สร้าง role
  - global role กำหนด
    - Overall เป็น Read ให้เห็น jenkins dashboard
    - Job เป็น Read ให้เห็น jobs/project/pipeline
  - item role กำหนด regex ตามชื่อ folder
- assign role
  - global role
  - item role

เขียน groovy pipeline

สร้าง folder

- กำหนด credential ของ folder
  - ใน pipeline ใช้คำสั่ง withCredentials ต้องกำหนดเป็นแบบ secret txt
    - โดย credentialsId คือ xxx
    - และ secret คือ ghp_xxx_github_secret 

สร้าง pipeline

ทดสอบรัน
