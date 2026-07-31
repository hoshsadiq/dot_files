---
name: guideline-proto-grpc
description: "Protocol Buffers and gRPC guidelines: proto file structure, service definitions, and code generation."
---

# Proto Models & gRPC Guidelines

> Source: projectcore/CODEGEN-GUIDELINE.md

## See Also
- `openapi-workflow.md` - OpenAPI spec workflow
- `hexagonal-arch.md` - Architecture layers

## Proto Models & gRPC Endpoints

When creating new gRPC endpoints:

1. **Update Proto Models First**
   - Update contracts in centralized proto models repository
   - Publish the updated proto models
   - Update dependencies in this project

2. **Local Proto Contracts** (if applicable)
   - Some projects may have local proto models for temporary use
   - These are typically used to generate OpenAPI specs or for development
   - Once centralized proto models are fully adopted, local folders should be removed

3. **Dependency Updates**
   - Update build configuration with new proto model versions

4. **OpenAPI Spec Regeneration** (CRITICAL for Frontend Integration)
   - **MUST regenerate OpenAPI spec BEFORE design phase** when new endpoints are needed
   - **Enhanced Script**: Use `./scripts/generate-openapi-spec.sh` for complete automation
   - **Automated Process**: Script now handles the entire workflow:
     - Fetches fresh proto files from centralized `project-core-proto-models` repository
     - Updates local proto contracts with latest definitions and common dependencies
     - Generates OpenAPI spec from updated proto files
     - Copies spec to web app directory
     - Runs `pnpm run openapi:update` to generate TypeScript client code
   - **One Command Solution**: Simply run `./scripts/generate-openapi-spec.sh` - no manual steps required
   - **Always Up-to-Date**: Ensures frontend has access to latest API definitions from centralized repository
   - **Failure to regenerate leads to inaccurate designs** with missing parameters or incorrect interfaces
   - Example: `getCases()` missing customer ID and filter parameters due to outdated spec

> **Note**: See [PROJECT-CONTEXT.md](PROJECT-CONTEXT.md) for project-specific proto repository URLs and dependency examples.

## Proto Models & gRPC Endpoints

When creating new gRPC endpoints:

1. **Update Proto Models First**
   - Update contracts in centralized `project-core-proto-models` repository
   - Publish the updated proto models
   - Update dependencies in this project (e.g., `com.projectcore.proto:*`)

2. **Automated Local Proto Sync**
   - **Enhanced Script**: `./scripts/generate-openapi-spec.sh` automatically fetches latest proto files
   - **Fresh Proto Files**: Script clones latest from `https://github.com/ikigai-digital/project-core-proto-models.git`
   - **Dependency Resolution**: Automatically copies common proto files to resolve import dependencies
   - **No Manual Updates**: Local `/contracts/` proto files are automatically synchronized

3. **Dependency Updates**
   - Update `build.gradle.kts` with latest proto model versions
   - Example: `implementation("com.projectcore.proto:customer-view-proto-kt:+")`
