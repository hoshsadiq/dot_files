---
name: guideline-hexagonal-arch
description: "Hexagonal architecture: layer definitions, access rules, package structure, and DDD alignment."
---

# Hexagonal Architecture Guidelines

> Source: projectcore/CODEGEN-GUIDELINE.md

## See Also
- `tdd-workflow.md` - TDD workflow for implementing features
- `testing-backend.md` - Testing patterns for architecture validation

## Hexagonal Architecture Rules

The architecture is enforced by `ModuleHexagonalArchitectureTest.kt`. All new classes must adhere to these layer rules:

### Layer Definitions
- **application**: Core business logic and use cases
- **api_ports**: API port interfaces (inbound adapters)
- **api_dto**: Data Transfer Objects for API layer
- **spi_ports**: SPI port interfaces (outbound adapters)
- **domain_models**: Domain entities and value objects
- **proto_models**: Protocol Buffer generated models
- **current_module_api**: Module-specific API adapters
- **current_module_spi**: Module-specific SPI adapters
- **api**: Cross-module API adapters
- **spi**: Cross-module SPI adapters

### Access Rules
- **current_module_api** can access: `api_ports`, `api_dto`, `domain_models`, `proto_models`
- **current_module_spi** can access: `spi_ports`, `domain_models`, `proto_models`, `api_ports`, `api_dto`
- **api** (cross-module) can access: `api_ports`, `api_dto`, `domain_models`, `proto_models`
- **spi** (cross-module) can access: `spi_ports`, `domain_models`, `proto_models`, `api_ports`, `api_dto`
- **spi_ports** can access: `domain_models`, `proto_models`, `api_dto`
- **api_ports** can access: `domain_models`, `proto_models`, `api_dto`
- **application** layer is forbidden from being accessed by other layers

## Package Structure

Organize code according to hexagonal architecture layers:

- **api/**: API adapters (inbound) - controllers, mappers, proto adapters
- **application/**: Core business logic
  - **port/api/**: API port interfaces and DTOs
  - **port/spi/**: SPI port interfaces
  - **domain/**: Domain models and entities
  - **service/**: Use case services
- **spi/**: SPI adapters (outbound) - persistence, external services, mappers

> **Note**: See [PROJECT-CONTEXT.md](PROJECT-CONTEXT.md) for the complete project-specific package structure.
