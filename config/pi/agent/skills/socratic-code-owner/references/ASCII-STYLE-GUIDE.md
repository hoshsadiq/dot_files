# ASCII Diagram Style Guide

Use these patterns when correcting misunderstandings. Pick the pattern that
best fits the concept. Prioritize readability over detail — these render in
terminals and chat windows, not design tools.

---

## Data Flow (request/response, pipelines, ETL)

```
  Request
    │
    ▼
┌──────────────┐    rejects     ┌─────────────┐
│ Auth Middle-  │──────────────▶│ 401 / 403   │
│ ware         │                └─────────────┘
└──────┬───────┘
       │ passes
       ▼
┌──────────────┐
│ Controller   │
└──────┬───────┘
       │
       ▼
┌──────────────┐    cache hit   ┌─────────────┐
│ Service Layer│──────────────▶│ Return cache │
└──────┬───────┘                └─────────────┘
       │ cache miss
       ▼
┌──────────────┐
│   Database   │
└──────────────┘
```

## State Machine (order lifecycle, auth states, job queues)

```
┌──────────┐  submit    ┌────────────┐  process   ┌───────────┐
│ DRAFT    │───────────▶│ SUBMITTED  │──────────▶│ RUNNING   │
└──────────┘            └────────────┘           └─────┬─────┘
                              │                        │
                              │ cancel                 ├── success ──▶ ┌───────────┐
                              ▼                        │               │ COMPLETED │
                        ┌───────────┐                  │               └───────────┘
                        │ CANCELLED │                  │
                        └───────────┘                  └── failure ──▶ ┌───────────┐
                                                                       │  FAILED   │
                                                                       └─────┬─────┘
                                                                             │ retry
                                                                             ▼
                                                                       ┌───────────┐
                                                                       │ RETRY     │
                                                                       │ (max 3x)  │
                                                                       └───────────┘
```

## Architecture / Service Map

```
┌─────────────────────────────────────────────┐
│                 API Gateway                  │
│            (rate limit, routing)             │
└──────┬──────────────┬──────────────┬─────────┘
       │              │              │
  ┌────▼────┐   ┌─────▼─────┐  ┌────▼─────┐
  │  Auth   │   │   Users   │  │  Orders  │
  │ Service │   │  Service  │  │  Service │
  └────┬────┘   └─────┬─────┘  └────┬─────┘
       │              │              │
       │         ┌────▼────┐        │
       │         │ Postgres │        │
       │         └─────────┘        │
       │                            │
       └────────────┬───────────────┘
                    ▼
             ┌────────────┐
             │ Event Bus  │
             │  (Kafka)   │
             └────────────┘
```

## Decision Tree (auth logic, feature flags, routing)

```
Is user authenticated?
├── YES ─▶ Has role permission?
│          ├── YES ─▶ Is resource owned by user?
│          │          ├── YES ─▶ ✅ Allow (200)
│          │          └── NO  ─▶ Is user admin?
│          │                     ├── YES ─▶ ✅ Allow (200)
│          │                     └── NO  ─▶ ❌ Forbidden (403)
│          └── NO  ─▶ ❌ Forbidden (403)
└── NO  ─▶ Is public endpoint?
           ├── YES ─▶ ✅ Allow (200)
           └── NO  ─▶ ❌ Unauthorized (401)
```

## Sequence / Timeline (request hops, webhook flow)

```
Client          API           Queue         Worker        Stripe
  │               │              │              │             │
  │──POST /pay──▶│              │              │             │
  │               │──enqueue───▶│              │             │
  │◀──202 Accepted│              │              │             │
  │               │              │──dequeue───▶│             │
  │               │              │              │──charge───▶│
  │               │              │              │◀──success──│
  │               │              │              │             │
  │               │◀─webhook────│──────────────│             │
  │◀──push notify─│              │              │             │
  │               │              │              │             │
```

## Comparison / Tradeoff Table

```
                    ┌─────────────┬─────────────┬─────────────┐
                    │   Polling   │  Webhooks   │  Streaming  │
┌───────────────────┼─────────────┼─────────────┼─────────────┤
│ Latency           │  High (sec) │  Low (ms)   │  Lowest     │
│ Complexity        │  Simple     │  Medium     │  High       │
│ Server load       │  High       │  Low        │  Medium     │
│ Missed events     │  Possible   │  Possible*  │  Rare       │
│ Needs public URL  │  No         │  Yes        │  No         │
└───────────────────┴─────────────┴─────────────┴─────────────┘
                              * unless retry/DLQ is configured
```

## Layered / Nested (middleware stack, call chain)

```
┌─────────────────────────────────────────────┐
│  Express App                                │
│  ┌────────────────────────────────────────┐ │
│  │  CORS Middleware                       │ │
│  │  ┌──────────────────────────────────┐  │ │
│  │  │  Auth Middleware                 │  │ │
│  │  │  ┌────────────────────────────┐  │  │ │
│  │  │  │  Rate Limiter             │  │  │ │
│  │  │  │  ┌──────────────────────┐ │  │  │ │
│  │  │  │  │  Route Handler      ◀── request hits here  │ │
│  │  │  │  └──────────────────────┘ │  │  │ │
│  │  │  └────────────────────────────┘  │  │ │
│  │  └──────────────────────────────────┘  │ │
│  └────────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
  response unwinds back out ──▶
```

---

## Formatting Rules

1. **Max width: 70 characters** — must fit in a terminal split pane
2. **Use box-drawing characters** where clarity helps: `┌ ┐ └ ┘ ─ │ ├ ┤ ┬ ┴ ┼`
3. **Use arrows** for direction: `▶ ▼ ◀ ▲` or `──▶ ──▶` for flow
4. **Label edges** — don't make the reader guess what a line means
5. **Annotate with plain text** — put a brief note next to the important part
6. **Whitespace is your friend** — let the diagram breathe
7. **One concept per diagram** — if you need two diagrams, use two
