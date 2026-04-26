# Task1Advanced — модуль Terraform для ВМ (Yandex Cloud)

Переиспользуемый модуль `modules/vm` создаёт виртуальную машину с загрузочным диском, **отдельным подключаемым диском данных**, сетевым интерфейсом в заданной подсети и установкой публичного SSH-ключа через метаданные. Внутри модуля **нет** захардкоженных имён окружений (`dev`/`stage`/`prod`) — только переменные; различия задаются в корневых конфигурациях `envs/*/`.

## Структура

```text
Task1Advanced/
  modules/vm/
    main.tf
    variables.tf
    outputs.tf
    versions.tf
  envs/
    dev/    — dev.tfvars.example → скопировать в dev.tfvars (локально)
    stage/  — stage.tfvars.example → stage.tfvars
    prod/   — prod.tfvars.example → prod.tfvars
```

Файлы `*.tfvars` с реальными `cloud_id`, `subnet_id` и SSH-ключом **в git не коммитятся** (см. `.gitignore`). В репозитории только шаблоны `*.tfvars.example`.

## Параметры модуля

| Переменная | Описание |
|------------|----------|
| `vm_name` | Имя ВМ |
| `cores` | Число vCPU |
| `memory_gb` | RAM, ГиБ |
| `disk_size_gb` | Размер **подключаемого** диска данных, ГБ |
| `subnet_id` | ID подсети для NIC |
| `ssh_public_key` | Публичный SSH-ключ (пользователь в образе: `ubuntu`) |
| `zone` | Зона доступности |

Дополнительно (необязательно): `boot_disk_size_gb`, `image_family`, `disk_type`, `enable_nat`, `platform_id` — см. `modules/vm/variables.tf`.

## Выходы модуля

- `vm_id`, `vm_name`
- `vm_internal_ip`, `vm_public_ip` (если `enable_nat = true`)
- `data_disk_id`, `data_disk_name`

Корневые конфигурации в `envs/*` пробрасывают часть значений наверх (см. `outputs.tf`).

## Предварительные условия

- [Terraform](https://developer.hashicorp.com/terraform/install) ≥ 1.3
- Аккаунт и каталог [Yandex Cloud](https://cloud.yandex.ru/)
- Созданная VPC и подсеть; в `.tfvars` указывается `subnet_id` в нужной зоне
- Аутентификация провайдера: как правило переменная окружения `YC_TOKEN` (OAuth-токен) либо настроенный профиль `yc`; см. [документацию провайдера](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs)

Перед первым запуском скопируйте шаблон: например `copy envs\dev\dev.tfvars.example envs\dev\dev.tfvars` (Windows) и отредактируйте `dev.tfvars`. В каждом каталоге `envs/*` задаются `cloud_id`, `folder_id`, `zone` и параметры модуля.

## Запуск по окружениям

Из корня нужного окружения, например **dev**:

```bash
cd envs/dev
terraform init
terraform fmt -recursive
terraform validate
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

**Stage:**

```bash
cd envs/stage
terraform init
terraform plan -var-file=stage.tfvars
terraform apply -var-file=stage.tfvars
```

**Prod:**

```bash
cd envs/prod
terraform init
terraform plan -var-file=prod.tfvars
terraform apply -var-file=prod.tfvars
```

Состояние Terraform хранится локально в каталоге окружения (файл `terraform.tfstate`), пока не настроен удалённый backend — это ожидаемо для Task1; отдельное задание посвящено S3-backend и CI/CD.

## Примечание по безопасности

Не коммитьте реальные секреты. При необходимости вынесите `ssh_public_key` и чувствительные ID в переменные окружения (`TF_VAR_...`) или в защищённое хранилище секретов вашего процесса.
