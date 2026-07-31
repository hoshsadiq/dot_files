---
name: guideline-i18n
description: "Internationalization guidelines: translation keys, locale handling, and frontend i18n patterns."
---

# Internationalization (i18n) Guidelines

> Source: projectcore/CODEGEN-GUIDELINE.md

## See Also
- `testing-frontend.md` - Frontend testing for i18n
- `code-quality.md` - Code quality standards

### 7. Internationalization (i18n) Implementation Guidelines

When adding internationalization support to frontend applications:

#### Translation Key Structure
- **Use flat key structure**: `cases_actions_create_case` instead of nested objects
- **Follow naming convention**: `{module}_{category}_{specific_name}`
- **Examples**:
  - `cases_tabs_all_cases` (tab labels)
  - `cases_actions_claim` (button actions)
  - `cases_columns_case_id` (table columns)
  - `cases_status_open` (status values)
  - `cases_priority_critical` (priority values)

#### Component Implementation
- **CRITICAL: Use React hooks for translations**: `import { useTypeSafeTranslation } from '@/app/i18n/useTypeSafeTranslation';`
- **NEVER import i18n directly in components**: `import { i18n } from '@/app/i18n/i18n';` ❌ WRONG - causes runtime errors
- **Use translation hook in component body**: `const { t } = useTypeSafeTranslation(); return t('cases_actions_create_case');`
- **Add translation keys to both language files**: Update both `en/common.json` and `ar/common.json`
- **Reuse existing translation files**: Don't create new namespace files unless absolutely necessary

#### Test Environment Setup
When components use i18n, tests will fail unless properly configured:

1. **Mock the main i18n instance in test setup** (`vitest.setup.ts`):
```typescript
import testI18n from '@app/i18n/test-i18n';

// Mock the main i18n instance to use testI18n in tests
vi.mock('@/app/i18n/i18n', () => ({
  i18n: testI18n,
}));
```

2. **Update test assertions to use translation keys**:
```typescript
// ❌ BAD - Hardcoded text that will fail when i18n is added
expect(screen.getByRole('button', { name: /create case/i })).toBeInTheDocument();

// ✅ GOOD - Use translation keys in tests
expect(screen.getByRole('button', { name: new RegExp(testI18n.t('cases_actions_create_case'), 'i') })).toBeInTheDocument();
```

3. **Ensure test-i18n.ts includes all necessary translation files**:
```typescript
import enCommon from '../../../public/locales/en/common.json';
// ... other imports

testI18n.use(initReactI18next).init({
  resources: {
    en: {
      common: enCommon,
      // ... other namespaces
    },
    // ... other languages
  },
});
```

#### Column Definitions and DataGrid Translation Pattern
When creating DataGrid columns that need translations:

**❌ WRONG - Using i18n.t() at module load time**:
```typescript
// This fails because i18n is not initialized when module loads
export const casesColumns: GridColDef<Case>[] = [
  {
    field: 'id',
    headerName: i18n.t('cases_columns_case_id'), // ❌ Fails - i18n not ready
    width: 150,
  },
];
```

**✅ CORRECT - Factory functions that accept translation function**:
```typescript
// Create factory functions that accept the translation function
export const createCasesColumns = (t: (key: string) => string): GridColDef<Case>[] => [
  {
    field: 'id',
    headerName: t('cases_columns_case_id'), // ✅ Works - t() available in component
    width: 150,
  },
];

// In component, call factory with translation function
const { t } = useTypeSafeTranslation();
const casesColumns = createCasesColumns(t);
```

**Why this pattern is required**:
- Column definitions are imported at module load time, before React components mount
- i18n system is not initialized until React app starts and components mount
- Translation functions (`t`) are only available within React component lifecycle
- Factory pattern defers translation until component has access to `t` function
