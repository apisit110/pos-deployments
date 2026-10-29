Write -> Plan -> Apply -> Manage -> Destroy

# HCL Basic

HCL (HashiCorp Configuration Language) คือภาษาที่ Terraform ใช้เขียนไฟล์ `.tf` เป็นภาษาแบบ declarative คือบอกแค่ว่าอยากได้ผลลัพธ์แบบไหน แล้ว Terraform จะจัดการสร้างให้เอง

# Basic Structure of an HCL Block

```hcl
<BLOCK_TYPE> "<LABEL_1>" "<LABEL_2>" {
  <ARGUMENT> = <VALUE>   # argument (key = value)

  <NESTED_BLOCK> {       # block ซ้อนข้างใน (ถ้ามี)
    ...
  }
}
```

| ส่วน         | ความหมาย                               | ตัวอย่าง                                     |
| ------------ | -------------------------------------- | -------------------------------------------- |
| Block type   | ประเภทของ block                        | `resource`, `provider`, `variable`, `output` |
| Labels       | ชื่อที่ใช้ระบุ block (มีได้ 0–2 label) | `"aws_instance" "web"`                       |
| Arguments    | กำหนดค่าในรูปแบบ `key = value`         | `ami = "ami-123"`                            |
| Nested block | block ที่อยู่ภายใน block อื่น          | `tags { ... }`, `ingress { ... }`            |

ตัวอย่าง

```hcl
resource "aws_instance" "web" {   # type="resource", labels="aws_instance","web"
  ami           = "ami-123456"
  instance_type = "t2.micro"
}

output "hello_world" {            # type="output", label="hello_world"
  value = "Hello, World!"
}
```

อ้างถึง resource จากที่อื่นด้วยรูปแบบ `<type>.<name>.<attribute>` เช่น `aws_instance.web.id`

## Write ไฟล์ configulation HCL files

สร้างไฟล์ main.tf

```hcl
output "hello_world" {
  value = "Hello, World!"
}
```

### Key components

- Configulation (.tf): เขียน config file
- Providers: AWS, Azure, GCP
- Resources: EC2, VPC, S3
- State File: สถานะปัจจุบันของ Code
- Variables: dynamic และ reuse
- Outputs: แสดงข้อมูลสำคัญหลังจาก apply

## Plan สำหรับ Preview ว่าจะทำอะไร

## Apply สำหรับ นำไปใช้

## Manage สำหรับ

## Destroy สำหรับลบ

terraform --help

| NO  | Command            | Description                                                                                                                                                             | Example                                                                                     |
| --- | ------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| 1   | terraform init     | เตรียม working directory: ดาวน์โหลด providers/modules และตั้งค่า backend สำหรับเก็บ state ต้องรันก่อนคำสั่งอื่นเสมอ (และรันใหม่เมื่อเพิ่ม/เปลี่ยน provider หรือ module) | `terraform init`<br>`terraform init -upgrade`                                               |
| 2   | terraform validate | ตรวจ syntax และความถูกต้องของไฟล์ .tf (เช่น ชื่อ argument, type) โดยไม่เชื่อมต่อ cloud และไม่แตะ state                                                                  | `terraform validate`                                                                        |
| 3   | terraform plan     | Preview ว่าจะ สร้าง (+) / แก้ไข (~) / ลบ (-) resource อะไรบ้าง โดยเทียบ config กับ state ปัจจุบัน ยังไม่มีการเปลี่ยนแปลงจริง                                            | `terraform plan`<br>`terraform plan -out=tfplan`<br>`terraform plan -var-file="dev.tfvars"` |
| 4   | terraform apply    | นำการเปลี่ยนแปลงไปใช้จริงกับ infrastructure แล้วอัปเดต state file (จะถามยืนยัน `yes` ก่อน)                                                                              | `terraform apply`<br>`terraform apply tfplan`<br>`terraform apply -auto-approve`            |
| 5   | terraform destroy  | ลบ resource ทั้งหมดที่ Terraform จัดการอยู่ใน state (จะถามยืนยัน `yes` ก่อน)                                                                                            | `terraform destroy`<br>`terraform destroy -target=aws_instance.web`                         |

variables file


terraform apply ทีเดียว มันจะอ่านทุกไฟล์ในโฟลเดอร์ แต่การแยกไฟล์ช่วยให้จัดการง่ายขึ้น เช่น:

| xxx          | xxx                                   |
| ------------ | ------------------------------------- |
| provider.tf  | เก็บค่าเชื่อมต่อ Cloud (AWS, GCP ฯลฯ) |
| variables.tf | เก็บตัวแปร (Variables)                |
| main.tf      | เก็บโค้ดสร้างทรัพยากรหลัก             |
| outputs.tf   | เก็บค่าที่ต้องการแสดงผลหลังรันเสร็จ   |


-----

terraform ต่อ aws ได้ยังไง

1. ผ่าน AWS CLI Configuration (~/.aws/credentials) นิยมใช้สำหรับ Local Development

~/.aws/credentials หรือ ~/.aws/config

เครื่อง host ที่รันคำสั่ง terraform ต้องติดตั้ง aws cli และ login ไว้อยู่แล้ว
โดย terraform สามารถกำหนด ว่าจะใช้ profile ใดที่ login ไว้ได้

```bash
aws configure
aws configure --profile dev
aws configure list-profiles
```

```hcl
provider "aws" {
  region  = "ap-southeast-1"
  profile = "my-production-profile"
}
```

2. ผ่าน Environment Variables - นิยมใช้กับ CI/CD (เช่น Jenkins, GitHub Actions)

```bash
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
# (ถ้าจำเป็น) export AWS_SESSION_TOKEN="your-session-token"
export AWS_REGION="ap-southeast-1"
```

---


- .terraform/ สร้างตอนรัน terraform init ข้างในเก็บตัว AWS provider plugin ที่ดาวน์โหลดมา (.terraform/providers/...) ไฟล์ใหญ่ ไม่ต้องแก้ ถ้าลบทิ้งก็แค่รัน init ใหม่
- .terraform.lock.hcl สร้างตอน init เหมือนกัน ไฟล์นี้ล็อกเวอร์ชัน provider ไว้ พร้อม hash สำหรับตรวจสอบ เครื่องอื่นหรือ CI ที่รัน init จะได้เวอร์ชันเดียวกันทุกครั้ง
- terraform.tfstate เป็นไฟล์สำคัญที่สุด เก็บว่า Terraform สร้างอะไรไปแล้วบ้างบน AWS และแต่ละตัวมีค่าอะไร
  - ทุกครั้งที่รัน plan หรือ apply Terraform จะเอา main.tf มาเทียบกับ state เพื่อดูว่าต้องสร้าง แก้ หรือลบอะไร
  - ถ้าไฟล์นี้หาย Terraform จะลืมว่าเคยสร้าง bucket ไว้แล้ว และจะพยายามสร้างซ้ำ
  - ห้ามแก้ด้วยมือ
- terraform.tfstate.backup เป็น state ฉบับก่อนหน้าหนึ่งรุ่น Terraform สำรองไว้ก่อนเขียนทับ state ทุกครั้ง

---

