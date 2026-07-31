# Worked Examples

These demonstrate what a full Socratic Code Owner Briefing session looks like
in practice. Use these as few-shot examples when the agent needs calibration.

---

## Example 1: Payment Webhook System

### Context
Agent just implemented a Stripe webhook handler with retry logic and
idempotency keys.

### Session

**Agent (Phase 2 — Agenda):**
```
I've identified 5 concepts you need to own:

1. Webhook verification and replay protection
2. Idempotency — why duplicate events don't cause duplicate charges
3. The retry queue and dead-letter behavior
4. Database transaction boundaries during webhook processing
5. What happens when Stripe is up but our DB is down

Let's start with #1.
```

**Agent (Phase 3 — Ask):**
```
Question 1: A webhook event arrives from Stripe, but an attacker could
also POST to our webhook URL with a fake payload. How does our handler
distinguish a real Stripe event from a forged one?
```

**User:** "We check the Stripe signature header?"

**Agent (Correct — brief confirmation):**
```
Exactly right. We verify the `Stripe-Signature` header using our webhook
signing secret via `stripe.webhooks.constructEvent()`. If the signature
doesn't match, we reject with 400 before any business logic runs. You
also correctly implied it's header-based, not body-based — the raw body
bytes matter, which is why we use the raw body parser on that route.

On to #2.
```

**Agent (Ask):**
```
Question 2: Stripe sometimes sends the same webhook event twice (network
retry, their bug, etc.). If we get `evt_abc123` twice in 30 seconds,
what prevents us from crediting the user's account twice?
```

**User:** "We probably check if we already processed it... in a database table?"

**Agent (Partially correct — correction with ASCII):**
```
You're on the right track — we do use the database. But it's more
specific than a general check. Here's the mechanism:

We store every processed event ID in an `idempotency_keys` table and
wrap the whole operation in a single database transaction. The event ID
column has a UNIQUE constraint, so the second insert fails atomically.

  Event arrives: evt_abc123
       │
       ▼
  ┌──────────────────────────────────┐
  │  BEGIN TRANSACTION               │
  │                                  │
  │  INSERT INTO idempotency_keys    │
  │  (event_id) VALUES (evt_abc123)  │
  │       │                          │
  │       ├── Success ──▶ Process    │
  │       │               payment    │
  │       │               logic      │
  │       │                          │
  │       └── UNIQUE violation ──▶   │
  │           ROLLBACK, return 200   │
  │                                  │
  │  COMMIT                          │
  └──────────────────────────────────┘

The key insight: returning 200 even on duplicates tells Stripe "I got it,
stop retrying." Returning 4xx/5xx would make Stripe keep sending it.

Quick check: Why do we return 200 instead of 409 Conflict on a duplicate?
```

**User:** "Because if we return an error, Stripe thinks we failed and keeps retrying?"

**Agent:**
```
Exactly. From Stripe's perspective, any non-2xx means "try again." So
we'd get exponential retries of something we already handled. 200 says
"message received" regardless of whether it was the first or fifth time.

On to #3.
```

---

## Example 2: React State Management Refactor

### Context
Agent refactored a React app from prop drilling to Zustand stores with
optimistic updates.

### Session (single question excerpt)

**Agent (Ask):**
```
Question 4: The user clicks "Add to Cart" and sees the item appear
instantly — that's the optimistic update. But the API call fails.
Walk me through what happens next from the user's perspective AND
from the state store's perspective.
```

**User:** "The item gets removed from the cart and we show an error toast?"

**Agent (Partially correct):**
```
The user-facing part is right — they see the item vanish and get an error
notification. But there's a subtlety in HOW the state rolls back that
matters for debugging.

The store doesn't just "remove the item." It reverts to a snapshot taken
BEFORE the optimistic update. Here's why that distinction matters:

  User clicks "Add to Cart"
       │
       ▼
  ┌─────────────────────────────┐
  │ 1. snapshot = store.copy()  │ ◀── save the ENTIRE previous state
  │ 2. store.cart.push(item)    │ ◀── optimistic: UI updates instantly
  │ 3. api.addToCart(item)      │ ◀── fire API call
  └──────────────┬──────────────┘
                 │
        ┌────────┴────────┐
        │                 │
     Success           Failure
        │                 │
        ▼                 ▼
   Do nothing.     store = snapshot  ◀── full rollback, not "remove item"
   API confirms.   toast("Failed")
```

If we just removed the item instead of restoring the snapshot, we'd lose
any OTHER state changes that happened between the click and the failure
(like quantity changes, coupon applications, etc.).

See: src/stores/cartStore.ts lines 34-52

Quick check: If the user changes item quantity while the add-to-cart API
is still in flight, and then the API fails — what happens to the quantity
change under our snapshot approach?
```

---

## Example 3: Scorecard Output

```
## Your Code Owner Scorecard

✅ SOLID (3/5):
   • Webhook signature verification — immediate, precise answer
   • Retry queue lifecycle — correctly traced the full path including DLQ
   • DB transaction boundaries — knew the isolation level and why it matters

⚠️  REVIEW (1/5):
   • Idempotency handling — had the right intuition but didn't know the
     UNIQUE constraint + transaction pattern. This is a critical production
     concept.
     → Review: src/webhooks/stripe.ts:78-95, src/db/migrations/003_idempotency.sql

❌ GAP (1/5):
   • DB-down scenario — assumed webhooks would just fail and Stripe retries
     would handle it. Missed our circuit breaker + local queue fallback.
     → Review: src/webhooks/circuitBreaker.ts, docs/disaster-recovery.md

Overall: 3/5 solid, 1 near-miss, 1 real gap. The idempotency gap is easy
to close with a 10-min code read. The circuit breaker gap needs a deeper
session — want me to walk you through it now?
```
