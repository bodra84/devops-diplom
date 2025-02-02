# Создание SA для Terraform
resource "yandex_iam_service_account" "sa" {
  folder_id = var.folder_id
  name      = var.SA_name
}

# Назначение роли editor для SA
resource "yandex_resourcemanager_folder_iam_member" "editor-sa" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

# Создание ключа авторизации для SA
resource "yandex_iam_service_account_key" "sa-auth-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "key for terraform service account"
  key_algorithm      = "RSA_4096"
}

# Получение информации о ключе авторизации
data "template_file" "sa-auth-key-json" {
  template = file("./auth_key.json.tmpl")
  vars = {
    key_id             = yandex_iam_service_account_key.sa-auth-key.id
    service_account_id = yandex_iam_service_account_key.sa-auth-key.service_account_id
    created_at         = yandex_iam_service_account_key.sa-auth-key.created_at
    key_algorithm      = yandex_iam_service_account_key.sa-auth-key.key_algorithm
    public_key         = jsonencode(yandex_iam_service_account_key.sa-auth-key.public_key)
    private_key        = jsonencode(yandex_iam_service_account_key.sa-auth-key.private_key)
  }
}

# Сохранение ключа в json-файл
resource "local_file" "save_key" {
  content    = data.template_file.sa-auth-key-json.rendered
  filename   = "${path.module}/${var.sa-auth-key-name}"
  depends_on = [data.template_file.sa-auth-key-json]
}

# Создание статического ключа доступа
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
}

# Получение информации о ключе авторизации
data "template_file" "static_access_key" {
  template = file("./credentials.tmpl")
  vars = {
    access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
    secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  }
}

# Сохранение статического ключа в файл
resource "local_file" "save_static_key" {
  content    = data.template_file.static_access_key.rendered
  filename   = "${path.module}/${var.sa-static-key-name}"
  depends_on = [data.template_file.static_access_key]
}

# Создание бакета для хранения стейт файла
resource "yandex_storage_bucket" "mybucket" {
  bucket     = var.bucket_name
  max_size   = var.bucket_size
  acl        = var.bucket_acl
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
}

