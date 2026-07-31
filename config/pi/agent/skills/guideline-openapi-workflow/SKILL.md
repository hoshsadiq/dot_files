---
name: guideline-openapi-workflow
description: "OpenAPI workflow: spec-first development, code generation, endpoint documentation."
---

# OpenAPI Workflow Guidelines

> Source: projectcore/CODEGEN-GUIDELINE.md

## See Also
- `proto-grpc.md` - Proto/gRPC endpoints
- `hexagonal-arch.md` - API layer architecture

## Enhanced OpenAPI Workflow

### When to Regenerate OpenAPI Spec
- **Before starting any frontend feature** that requires new or modified API endpoints
- **After proto model updates** in the centralized repository
- **When API interface designs seem outdated** or missing expected parameters
- **As part of feature design phase** to ensure accurate API contracts

### Automated Regeneration Process
```bash
# Single command handles everything:
./scripts/generate-openapi-spec.sh
```

**What the script does automatically:**
1. **Fetches Latest Proto Files**: Clones fresh proto definitions from centralized repository
2. **Updates Local Contracts**: Replaces local proto files with latest versions
3. **Resolves Dependencies**: Copies common proto files to resolve import issues
4. **Generates OpenAPI Spec**: Uses buf to create swagger specification
5. **Updates Client Code**: Runs `pnpm run openapi:update` to generate TypeScript clients
6. **Validates Results**: Ensures all required services and endpoints are present

**No manual steps required** - the script handles the complete workflow from proto sync to client code generation.
