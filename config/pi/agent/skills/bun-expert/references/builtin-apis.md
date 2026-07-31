# Built-in APIs Reference

Doc-aligned quick reference for Bun native APIs.

---

## Bun.serve()

HTTP/HTTPS server with route dispatch and WebSocket upgrades.

```typescript
Bun.serve({
  port: 3000,
  routes: {
    "/": new Response("Home"),
    "/users/:id": (req) => Response.json({ id: req.params.id }),
    "/api/items": {
      GET: () => Response.json([]),
      POST: async (req) => Response.json(await req.json(), { status: 201 }),
    },
    "/favicon.ico": Bun.file("./public/favicon.ico"),
  },
  fetch() {
    return new Response("Not Found", { status: 404 });
  },
});
```

### Server control

```typescript
const server = Bun.serve({ fetch: () => new Response("ok") });

server.reload({ fetch: () => new Response("updated") });
server.stop();

console.log(server.port, server.hostname, server.url);
```

### TLS

```typescript
Bun.serve({
  tls: {
    key: Bun.file("./key.pem"),
    cert: Bun.file("./cert.pem"),
  },
  fetch() {
    return new Response("secure");
  },
});
```

---

## WebSockets

```typescript
interface WsData {
  user: string;
}

Bun.serve<WsData>({
  routes: {
    "/ws": (req, server) => {
      const user = new URL(req.url).searchParams.get("user") ?? "anon";
      if (server.upgrade(req, { data: { user } })) return;
      return new Response("Upgrade failed", { status: 400 });
    },
  },
  websocket: {
    open(ws) {
      ws.subscribe("chat");
      ws.publish("chat", `${ws.data.user} joined`);
    },
    message(ws, message) {
      ws.publish("chat", `${ws.data.user}: ${message}`);
    },
    close(ws) {
      ws.unsubscribe("chat");
    },
  },
  fetch() {
    return new Response("Not Found", { status: 404 });
  },
});
```

---

## SQL

### `sql` (shared singleton)

```typescript
import { sql } from "bun";

const users = await sql`SELECT * FROM users WHERE active = ${true}`;
```

### `SQL` (explicit clients)

```typescript
import { SQL } from "bun";

const pg = new SQL(process.env.POSTGRES_URL!);
const mysql = new SQL(process.env.MYSQL_URL!);
const sqlite = new SQL("sqlite://local.sqlite");

const rows = await pg`SELECT NOW()`;
await pg.close();
```

Aliases `Bun.sql` and `Bun.SQL` are also available.

---

## SQLite (`bun:sqlite`)

```typescript
import { Database } from "bun:sqlite";

const db = new Database("app.sqlite");
db.run("CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, name TEXT)");
db.run("INSERT INTO users (name) VALUES (?)", ["Alice"]);

const users = db.query("SELECT * FROM users").all();
console.log(users);

db.close();
```

---

## S3-Compatible Storage

Use Bun's built-in helpers for S3, R2, and compatible providers.

```typescript
import { s3, S3Client } from "bun";

const file = s3.file("path/to/file.json"); // Uses default env-backed bucket config
const text = await file.text();
await file.write("hello");

const client = new S3Client({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID!,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY!,
  region: process.env.AWS_REGION ?? "us-east-1",
  bucket: "my-bucket",
});

const other = client.file("path/to/object.txt");
await other.write("ok");
```

---

## Redis

```typescript
import { redis, RedisClient } from "bun";

await redis.set("key", "value");
const value = await redis.get("key");

const custom = new RedisClient("redis://localhost:6379");
await custom.set("hello", "world");
await custom.close();
```

`redis` uses `REDIS_URL` by default.

---

## Bun.cron

Register and manage OS-level cron jobs (crontab on Linux, launchd on macOS, Task Scheduler on Windows).

### Parse a cron expression

```typescript
const next = Bun.cron.parse("*/5 * * * *"); // next matching Date
```

### Register a cron job

```typescript
Bun.cron("cleanup-temp", "0 3 * * *", {
  scheduled() {
    console.log("Running nightly cleanup");
  },
});
```

### Remove a registered job

```typescript
Bun.cron.remove("cleanup-temp");
```

---

## Bun.$ (Shell)

```typescript
import { $ } from "bun";

const whoami = await $`whoami`.text();
const files = await $`ls -1`.lines();

const result = await $`grep "needle" README.md`.nothrow();
if (result.exitCode !== 0) {
  console.log("not found");
}

await $`echo ${"unsafe; rm -rf /"}`; // Interpolations are escaped
```

---

## File and Utility APIs

```typescript
const text = await Bun.file("./README.md").text();
await Bun.write("./out.txt", text);

const hash = new Bun.CryptoHasher("sha256").update("data").digest("hex");
const passwordHash = await Bun.password.hash("secret");
const ok = await Bun.password.verify("secret", passwordHash);
```

---

## Primary Docs

- https://bun.com/docs/runtime/http/routing
- https://bun.com/docs/runtime/http/websockets
- https://bun.com/docs/runtime/sql
- https://bun.com/docs/runtime/sqlite
- https://bun.com/docs/runtime/s3
- https://bun.com/docs/runtime/redis
- https://bun.com/docs/runtime/cron
- https://bun.com/docs/runtime/shell
- https://bun.com/docs/api/file-io
- https://bun.com/docs/api/hashing
