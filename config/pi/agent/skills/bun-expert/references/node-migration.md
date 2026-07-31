# Node.js Migration Reference

Practical guide for migrating Node.js projects to Bun using current Bun docs.

---

## Compatibility Reality Check

Bun provides broad Node.js compatibility, but migration should still be verified
with your own test suite and production workflows.

Use Bun's compatibility pages as source of truth:
- Node.js APIs: https://bun.com/docs/runtime/nodejs-apis
- Node.js globals: https://bun.com/docs/runtime/nodejs-globals

Notable Bun behavior for migration:
- Bun exposes Node globals like `process`, `Buffer`, and friends.
- In ESM, Bun also provides `__dirname`, `__filename`, and `require()` for compatibility.

---

## Migration Steps

### 1. Install Bun

```bash
curl -fsSL https://bun.sh/install | bash
```

### 2. Install dependencies with Bun

```bash
bun install
```

If migrating from Yarn or pnpm lockfiles:

```bash
bun pm migrate
```

### 3. Update scripts incrementally

```json
{
  "scripts": {
    "dev": "bun --watch src/index.ts",
    "start": "bun src/index.ts",
    "test": "bun test",
    "build": "bun build ./src/index.ts --outdir ./dist"
  }
}
```

### 4. Keep Node compatibility mode available where needed

```bash
bun --bun run <script>
```

Use this while migrating scripts/packages that still assume a Node runtime.

### 5. Validate in CI before removing fallbacks

```yaml
- uses: oven-sh/setup-bun@v2
  with:
    bun-version: latest
- run: bun install --frozen-lockfile
- run: bun test
- run: bun run build
```

---

## API Mapping Patterns

Use these as migration defaults:

| Existing Node stack | Bun-first option |
|---|---|
| Jest/Vitest | `bun test` |
| esbuild/webpack scripts | `bun build` |
| dotenv bootstrap | Bun automatic `.env` loading |
| child_process shell snippets | `Bun.$` |
| Custom HTTP framework for simple APIs | `Bun.serve()` |

For databases/storage:
- SQL: `sql` / `SQL` from `bun`
- Redis: `redis` / `RedisClient` from `bun`
- S3-compatible object storage: `s3` / `S3Client` from `bun`
- Embedded SQLite: `bun:sqlite`

---

## `.env` Behavior

Bun automatically loads `.env` files in this order:

1. `.env`
2. `.env.{NODE_ENV}`
3. `.env.local`

If your Node app used `dotenv`, remove duplicate loading to avoid confusion.

---

## Common Pitfalls

1. Assuming feature parity without running tests.
2. Migrating runtime and package manager in one large step without checkpoints.
3. Keeping old Jest/Vitest-specific assumptions in test scripts.
4. Forgetting to pin/verify Bun version in CI during rollout.

---

## Primary Docs

- https://bun.com/docs/guides/ecosystem/migrate-from-nodejs
- https://bun.com/docs/runtime/nodejs-apis
- https://bun.com/docs/runtime/nodejs-globals
- https://bun.com/docs/runtime/env
- https://bun.com/docs/cli/pm
- https://bun.com/docs/cli/test
- https://bun.com/docs/cli/build
