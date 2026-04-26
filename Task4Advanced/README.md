# Task4Advanced

DDD: bounded contexts, агрегаты, междоменные события, целевая событийная архитектура (Event Storming) и обоснование EDA.

Архитектура согласована с C4 (контейнеры) в [`../Task3Advanced/c4-containers.drawio`](../Task3Advanced/c4-containers.drawio): Event Backbone, API Gateway & Ingestion, Stream Processing & Data Products, Data Access & Governance, Legacy Integration Bridge.

**Ограничение по витрине/self-service (по заданию):** в портал самообслуживания **не** попадают медицинская карта, анамнез/история болезни и **результаты** медицинских/ИИ-исследований; для аналитики используются **обезличенные** и/или **агрегированные** data products. События из клинического/ИИ-контекстов всё равно публикуются для **авторизованных** подписчиков; правила публикации и read-моделей описаны в `events.md` и `bounded-contexts.md`.

## Состав артефактов

| Файл | Содержание |
|------|------------|
| [`bounded-contexts.md`](bounded-contexts.md) | Bounded contexts, взаимодействия, Mermaid: источники и подписчики |
| [`event-storming.md`](event-storming.md) | Event Storming: легенда (policy, read model, hot spot), сценарии, Mermaid |
| [`aggregates.md`](aggregates.md) | Агрегаты: границы, инварианты, ключи |
| [`events.md`](events.md) | Каталог событий; разделение `patientId` / `patientPseudoId` / `anonymizedSubjectId`, профили A/B |
| [`justification.md`](justification.md) | Обоснование событийного подхода vs Camel + DWH |

## Self-check (критерии задания и согласованность с Task3)

- Есть **схема bounded contexts** и **Event Storming** (Markdown + Mermaid), плюс `aggregates.md`, `events.md`, `justification.md`.
- В модели отражены примеры из ТЗ: **кредитный договор**, **новый пациент**, **исследование ИИ** — в виде доменных событий и связей **источник / подписчик** (см. `events.md`).
- Для self-service: витрины и события **аналитического** профиля **с** `patientPseudoId` (для ИИ — `anonymizedSubjectId` **в** **той** **же** **роли**), **без** операционного `patientId` (см. `events.md`); PHI **в** self-service-контрактах **не** допускается.
- Вопросы ревьюеру по ТЗ **не** включены.
- **Нет** риторических вопросов в тексте артефактов (курс).

| Элемент C4 (Task3) | Где отражено в Task4 |
|--------------------|----------------------|
| API Gateway & Ingestion, Schema Validator, Policy Enricher, DLQ | `bounded-contexts.md` (BC_PLAT), `events.md` (валидация, DLQ) |
| Event Backbone, Stream Processing, Data Lakehouse | `bounded-contexts.md`, `event-storming.md` |
| Data Access & Governance, self-service зона | `bounded-contexts.md` (BC_GOV), `events.md` (self-service) |
| Legacy Integration Bridge, DWH | `aggregates.md` (BC_LACL), `justification.md` (мост) |
