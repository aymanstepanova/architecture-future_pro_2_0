# Каталог доменных событий

Транспорт: **Event Backbone** (Kafka-compatible) из C4; контракты: Avro/JSON + Schema Registry (см. Task2/Task3, риски R3).  
**Минимальный контракт** = поля, необходимые для **идентификации** события, маршрутизации и **безопасной** downstream-логики.

## Пациент: внутренний `patientId` и внешние `patientPseudoId` / `anonymizedSubjectId`

Чтобы в self-service **не** воспринималось как утечка **того же** идентификатора, что в EMR/оперативных системах, вводим **жёсткое** разделение.

| Идентификатор | Где используется | Смысл |
|---------------|------------------|--------|
| `patientId` | Только в BC_CLIN; интеграции в **закрытом** контуре; BC_LACL при миграции — **только** по **отдельной** политике ACL | **Внутренний** суррогатный ключ пациента **в** **клиническом** контуре. **Не** попадает **в** топики и схемы, из которых строят **витрины** self-service. |
| `patientPseudoId` | События в `Event Backbone` для **аналитики** (в т.ч. self-service) после Policy Enricher/RLS | **Стабильный** внешний псевдоним для **склейки** **без** раскрытия `patientId` аналитику. Связь `patientId` → `patientPseudoId` **только** в **управляемом** хранилище (BC_GOV/зона BC_CLIN), **не** в read-моделях портала. |
| `anonymizedSubjectId` | BC_AIRES, исследовательский контур | Та **же** роль, что у `patientPseudoId` для **внешнего** субъекта в статистике; имя согласуется **с** `patientPseudoId` в глоссарии BC_GOV, чтобы **не** плодить **лишние** несогласованные токены. |

**Правило публикации:** в топик/схему, предназначенные **для** аналитики и self-service, поле `patientId` **недопустимо**; **обязателен** `patientPseudoId` (или **эквивалент** **по** глоссарию). Вариант: два профиля (отдельные топики) — `clin.patient.pseudo.v1` (без `patientId`) и `clin.patient.internal.v1` (только **для** ACL/миграции) — либо **обогащение** / **удаление** полей **на** границе BC_PLAT (Policy Enricher).

## Опорные события (из ТЗ + кейс)

| Имя (техн.) | RU-формулировка (бизнес) | Контекст-источник | Семантика | Кто подписан (примеры) | Минимальный контракт (поля) |
|-------------|--------------------------|-------------------|------------|-------------------------|------------------------------|
| `PatientRegistered` | Зарегистрирован новый пациент | BC_CLIN | В клинике зафиксирован **внутренний** `patientId`. В **аналитическую** шину — **только** профиль с `patientPseudoId` (см. таблицу **выше**). | BC_DPROD, BC_GOV, BC_LACL(1) | **A — internal/ACL:** `eventId`, `occurredAt`, `schemaVersion`, `patientId`, `clinicId`, `registrationChannel`. **B — аналитика/self-service:** `eventId`, `occurredAt`, `schemaVersion`, `patientPseudoId`, `clinicId` (как **разрешено** политикой), `registrationChannel`; `patientId` **отсутствует** |
| `CreditContractCreated` | Создан кредитный договор | BC_FINT | Договор `contractId` **создан** и **валиден** в юрид/опер. смысле. | BC_DPROD, BC_GOV, BC_LACL(1) | `eventId`, `occurredAt`, `schemaVersion`, `contractId`, `productCode`, `currency`, `amount` (minor units), `tenor`, `status` = `CREATED` |
| `AIResearchStudyCompleted` | Пройдено/завершено исследование (ИИ) | BC_AIRES | `studyId` **завершён** успешно, без **сырых результатов** в self-service-канале. | BC_DPROD (агрегаты), внутр. AI, BC_LACL(1) | `eventId`, `occurredAt`, `schemaVersion`, `studyId`, `modality`(2), `anonymizedSubjectId` (роль **внешнего** субъекта, **не** `patientId` — см. **раздел** **о** **идентификаторах**), `completedAt` |

1. **BC_LACL** — **только** в фазе миграции и **по отдельным** ACL-мэппингам; `patientId` **не** направлять **в** **потоки** self-service.  
2. `modality` — укрупнённый тип/каталожный код, **без** сырых медицинских BLOB, если **не** закрытый topic.

## Допуск в self-service (критично по условиям задания)

| Канал / потребитель | `PatientRegistered` | `CreditContractCreated` | `AIResearchStudyCompleted` |
|---------------------|---------------------|-------------------------|----------------------------|
| **Self-service BI (обезл./агрегаты)** | Да: **только** `patientPseudoId` и (по политике) `clinicId` как **срез**; `patientId` **запрещён**; **агрегатные** метрики. | Да: без PII, если витрина не требует. | **Да:** **без** результатов и сырья; **когорта/срез/время**; `anonymizedSubjectId` — **отдельный** **внешний** токен, **без** связи с `patientId` **в** **витрине**. |
| **Легаси DWH sync** | По **отдельному** ACL, может быть PII, если **не** self-service. | Как в банк. сегменте, по политике. | **Не** публиковать результаты в self-service-шину. |

**Инварианты публикации:** `eventId` **глобально уникален**; `schemaVersion` инкрементальна; в BC_PLAT: **Schema Validator** + **Policy Enricher** (C4) до записи в топик.

## Топикинг (пример, не prescriptive)

- `clin.patient.pseudo.v1` — `PatientRegistered`, профиль B (без `patientId`, с `patientPseudoId`)  
- `clin.patient.internal.v1` — `PatientRegistered`, профиль A (только **для** ACL/миграции)  
- `fintech.credit.v1` — `CreditContractCreated`  
- `airesearch.study.v1` — `AIResearchStudyCompleted`  

**Dead Letter:** при `schema` mismatch или `policy` deny — `DLQ` (компонент Task3) с replay-политикой (риск R4 в Task3).

## Идентификаторы и взаимосвязи

- `contractId`, `studyId`, `patientPseudoId` (и при необходимости `anonymizedSubjectId` **в** **той** **же** **роли** **в** схеме ИИ) — **UUID v4** или эквивалент **без** коллизий **в** **зоне** **выдачи**.  
- `patientId` — **только** **в** операционной **зоне** BC_CLIN/ACL; маппинг `patientId` → `patientPseudoId` **не** раскрывается **в** self-service.  
- `occurredAt` — время **фиксации** **в** источнике, **не** время **приёма** **в** брокер.  
- Подписка **на** **нерелевантные** **топики** **по** умолчанию **запрещена** (ACL, **принцип** **минимума** **данных**).

## Расширяемость

Новое направление/бизнес: заводится **новая** `schema` / topic в пределах домена, с **каталожной** регистрацией в BC_GOV и **контрактами** (риск R3, Task3).
