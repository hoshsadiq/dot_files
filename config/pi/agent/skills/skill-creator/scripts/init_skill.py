#!/usr/bin/env python3
"""
Skill Initializer - Creates a new OpenCode skill from template

Usage:
    init_skill.py <skill-name> --path <path>

Examples:
    init_skill.py my-new-skill --path ~/.config/opencode/skill
    init_skill.py my-api-helper --path ~/.config/opencode/skill
    init_skill.py custom-skill --path /custom/location
"""

import sys
import re
import os
from pathlib import Path


SKILL_TEMPLATE = """---
name: {skill_name}
description: "TODO: Complete and informative explanation of what the skill does and when to use it. Include WHEN to use this skill - specific scenarios, file types, or tasks that trigger it."
license: MIT
compatibility: opencode
metadata:
  audience: "TODO: who is this for?"
  workflow: "TODO: what workflow does this support?"
---

# {skill_title}

## Overview

[TODO: 1-2 sentences explaining what this skill enables]

## Structuring This Skill

[TODO: Choose the structure that best fits this skill's purpose. Common patterns:

**1. Workflow-Based** (best for sequential processes)
- Works well when there are clear step-by-step procedures
- Example: DOCX skill with "Workflow Decision Tree" → "Reading" → "Creating" → "Editing"
- Structure: ## Overview → ## Workflow Decision Tree → ## Step 1 → ## Step 2...

**2. Task-Based** (best for tool collections)
- Works well when the skill offers different operations/capabilities
- Example: PDF skill with "Quick Start" → "Merge PDFs" → "Split PDFs" → "Extract Text"
- Structure: ## Overview → ## Quick Start → ## Task Category 1 → ## Task Category 2...

**3. Reference/Guidelines** (best for standards or specifications)
- Works well for brand guidelines, coding standards, or requirements
- Example: Brand styling with "Brand Guidelines" → "Colors" → "Typography" → "Features"
- Structure: ## Overview → ## Guidelines → ## Specifications → ## Usage...

**4. Capabilities-Based** (best for integrated systems)
- Works well when the skill provides multiple interrelated features
- Example: Product Management with "Core Capabilities" → numbered capability list
- Structure: ## Overview → ## Core Capabilities → ### 1. Feature → ### 2. Feature...

Patterns can be mixed and matched as needed. Most skills combine patterns (e.g., start with task-based, add workflow for complex operations).

Delete this entire "Structuring This Skill" section when done - it's just guidance.]

## [TODO: Replace with the first main section based on chosen structure]

[TODO: Add content here. See examples in existing skills:
- Code samples for technical skills
- Decision trees for complex workflows
- Concrete examples with realistic user requests
- References to scripts/templates/references as needed]

## Resources

This skill includes example resource directories that demonstrate how to organize different types of bundled resources:

### scripts/
Executable code (Python/Bash/etc.) that can be run directly to perform specific operations.

**Examples from other skills:**
- PDF skill: `fill_fillable_fields.py`, `extract_form_field_info.py` - utilities for PDF manipulation
- DOCX skill: `document.py`, `utilities.py` - Python modules for document processing
- Loki-log-query skill: `query.py`, `tail.py` - scripts with venv for Loki API calls

**Appropriate for:** Python scripts, shell scripts, or any executable code that performs automation, data processing, or specific operations.

**Python Scripts Best Practice:**
- **Use venv** if the script requires external packages
- Create `venv/` directory in the skill folder
- Use `./venv/bin/python scripts/script.py` to run
- Add `requirements.txt` for dependencies
- Add `venv/` to `.gitignore`

**Note:** Scripts may be executed without loading into context, but can still be read by OpenCode for patching or environment adjustments.

### references/
Documentation and reference material intended to be loaded into context to inform OpenCode's process and thinking.

**Examples from other skills:**
- Product management: `communication.md`, `context_building.md` - detailed workflow guides
- BigQuery: API reference documentation and query examples
- Finance: Schema documentation, company policies

**Appropriate for:** In-depth documentation, API references, database schemas, comprehensive guides, or any detailed information that OpenCode should reference while working.

### assets/
Files not intended to be loaded into context, but rather used within the output OpenCode produces.

**Examples from other skills:**
- Brand styling: PowerPoint template files (.pptx), logo files
- Frontend builder: HTML/React boilerplate project directories
- Typography: Font files (.ttf, .woff2)

**Appropriate for:** Templates, boilerplate code, document templates, images, icons, fonts, or any files meant to be copied or used in the final output.

---

**Any unneeded directories can be deleted.** Not every skill requires all three types of resources.
"""

EXAMPLE_SCRIPT = '''#!/usr/bin/env python3
"""
Example helper script for {skill_name}

This is a placeholder script that can be executed directly.
Replace with actual implementation or delete if not needed.

Example real scripts from other skills:
- pdf/scripts/fill_fillable_fields.py - Fills PDF form fields
- pdf/scripts/convert_pdf_to_images.py - Converts PDF pages to images
"""

def main():
    print("This is an example script for {skill_name}")
    # TODO: Add actual script logic here
    # This could be data processing, file conversion, API calls, etc.

if __name__ == "__main__":
    main()
'''

EXAMPLE_REFERENCE = """# Reference Documentation for {skill_title}

This is a placeholder for detailed reference documentation.
Replace with actual reference content or delete if not needed.

Example real reference docs from other skills:
- product-management/references/communication.md - Comprehensive guide for status updates
- product-management/references/context_building.md - Deep-dive on gathering context
- bigquery/references/ - API references and query examples

## When Reference Docs Are Useful

Reference docs are ideal for:
- Comprehensive API documentation
- Detailed workflow guides
- Complex multi-step processes
- Information too lengthy for main SKILL.md
- Content that's only needed for specific use cases

## Structure Suggestions

### API Reference Example
- Overview
- Authentication
- Endpoints with examples
- Error codes
- Rate limits

### Workflow Guide Example
- Prerequisites
- Step-by-step instructions
- Common patterns
- Troubleshooting
- Best practices
"""

EXAMPLE_ASSET = """# Example Asset File

This placeholder represents where asset files would be stored.
Replace with actual asset files (templates, images, fonts, etc.) or delete if not needed.

Asset files are NOT intended to be loaded into context, but rather used within
the output OpenCode produces.

Example asset files from other skills:
- Brand guidelines: logo.png, slides_template.pptx
- Frontend builder: hello-world/ directory with HTML/React boilerplate
- Typography: custom-font.ttf, font-family.woff2
- Data: sample_data.csv, test_dataset.json

## Common Asset Types

- Templates: .pptx, .docx, boilerplate directories
- Images: .png, .jpg, .svg, .gif
- Fonts: .ttf, .otf, .woff, .woff2
- Boilerplate code: Project directories, starter files
- Icons: .ico, .svg
- Data files: .csv, .json, .xml, .yaml

Note: This is a text placeholder. Actual assets can be any file type.
"""

EXAMPLE_REQUIREMENTS = """# Python dependencies for {skill_title}
# Install with: pip install -r requirements.txt

# Add your dependencies here, for example:
# requests>=2.31.0
# pandas>=2.0.0
# numpy>=1.24.0

# Uncomment and update the line below when you add dependencies:
# -r requirements.txt
"""

EXAMPLE_GITIGNORE = """# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Virtual environments
venv/
ENV/
env/
.venv

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Logs
*.log
"""


def validate_skill_name(skill_name):
    """
    Validate skill name against OpenCode naming rules.
    
    Rules:
    - 1-64 characters
    - Lowercase alphanumeric with single hyphens
    - Cannot start or end with hyphen
    - Cannot contain consecutive hyphens
    """
    if not skill_name:
        return False, "Skill name cannot be empty"
    
    if len(skill_name) < 1 or len(skill_name) > 64:
        return False, f"Skill name must be 1-64 characters (got {len(skill_name)})"
    
    if not re.match(r'^[a-z0-9]+(-[a-z0-9]+)*$', skill_name):
        return False, "Skill name must be lowercase alphanumeric with single hyphens"
    
    return True, "Valid skill name"


def title_case_skill_name(skill_name):
    """Convert hyphenated skill name to Title Case for display."""
    return ' '.join(word.capitalize() for word in skill_name.split('-'))


def init_skill(skill_name, path):
    """
    Initialize a new skill directory with template SKILL.md.

    Args:
        skill_name: Name of the skill
        path: Path where the skill directory should be created

    Returns:
        Path to created skill directory, or None if error
    """
    # Validate skill name
    valid, message = validate_skill_name(skill_name)
    if not valid:
        print(f"❌ Error: {message}")
        return None
    
    # Determine skill directory path
    skill_dir = Path(path).resolve() / skill_name

    # Check if directory already exists
    if skill_dir.exists():
        print(f"❌ Error: Skill directory already exists: {skill_dir}")
        return None

    # Create skill directory
    try:
        skill_dir.mkdir(parents=True, exist_ok=False)
        print(f"✅ Created skill directory: {skill_dir}")
    except Exception as e:
        print(f"❌ Error creating directory: {e}")
        return None

    # Create SKILL.md from template
    skill_title = title_case_skill_name(skill_name)
    skill_content = SKILL_TEMPLATE.format(
        skill_name=skill_name,
        skill_title=skill_title
    )

    skill_md_path = skill_dir / 'SKILL.md'
    try:
        skill_md_path.write_text(skill_content)
        print("✅ Created SKILL.md")
    except Exception as e:
        print(f"❌ Error creating SKILL.md: {e}")
        return None

    # Create resource directories with example files
    try:
        # Create scripts/ directory with example script
        scripts_dir = skill_dir / 'scripts'
        scripts_dir.mkdir(exist_ok=True)
        example_script = scripts_dir / 'example.py'
        example_script.write_text(EXAMPLE_SCRIPT.format(skill_name=skill_name))
        example_script.chmod(0o755)
        print("✅ Created scripts/example.py")

        # Create references/ directory with example reference doc
        references_dir = skill_dir / 'references'
        references_dir.mkdir(exist_ok=True)
        example_reference = references_dir / 'api_reference.md'
        example_reference.write_text(EXAMPLE_REFERENCE.format(skill_title=skill_title))
        print("✅ Created references/api_reference.md")

        # Create assets/ directory with example asset placeholder
        assets_dir = skill_dir / 'assets'
        assets_dir.mkdir(exist_ok=True)
        example_asset = assets_dir / 'example_asset.txt'
        example_asset.write_text(EXAMPLE_ASSET)
        print("✅ Created assets/example_asset.txt")

        # Create .gitignore for venv isolation
        gitignore_path = skill_dir / '.gitignore'
        gitignore_path.write_text(EXAMPLE_GITIGNORE)
        print("✅ Created .gitignore (includes venv/)")

        # Create requirements.txt for dependencies
        requirements_path = skill_dir / 'requirements.txt'
        requirements_path.write_text(EXAMPLE_REQUIREMENTS.format(skill_title=skill_title))
        print("✅ Created requirements.txt (add dependencies here)")

        # Create venv/ directory for isolated Python environment
        venv_dir = skill_dir / 'venv'
        venv_dir.mkdir(exist_ok=True)
        # Create a placeholder file to ensure the directory is tracked
        venv_readme = venv_dir / '.gitkeep'
        venv_readme.write_text("# Virtual environment directory\n# Run: python3 -m venv venv\n# Then: source venv/bin/activate && pip install -r requirements.txt\n")
        print("✅ Created venv/ directory (isolated Python environment)")
    except Exception as e:
        print(f"❌ Error creating resource directories: {e}")
        return None

    # Print next steps
    print(f"\n✅ Skill '{skill_name}' initialized successfully at {skill_dir}")
    print("\nNext steps:")
    print("1. Edit SKILL.md to complete the TODO items and update the description")
    print("2. Customize or delete the example files in scripts/, references/, and assets/")
    print(f"3. Create virtual environment: cd {skill_dir} && python3 -m venv venv")
    print("4. Install dependencies: source venv/bin/activate && pip install -r requirements.txt")
    print("5. Run scripts with: ./venv/bin/python scripts/<script>.py")
    print("6. Run quick_validate.py when ready to check the skill structure")

    return skill_dir


def main():
    if len(sys.argv) < 2:
        print("Usage: init_skill.py <skill-name> [OPTIONS]")
        print("\nSkill name requirements:")
        print("  - Hyphen-case identifier (e.g., 'data-analyzer')")
        print("  - Lowercase letters, digits, and hyphens only")
        print("  - 1-64 characters")
        print("  - Must match directory name exactly")
        print("\nOptions:")
        print("  --path <path>    Install to specific path")
        print("  --local          Install locally (./.opencode/skill/)")
        print("  --global         Install globally (~/.config/opencode/skill/)")
        print("\nExamples:")
        print("  init_skill.py my-new-skill --local")
        print("  init_skill.py my-new-skill --global")
        print("  init_skill.py my-new-skill --path /custom/location")
        sys.exit(1)

    skill_name = sys.argv[1]
    
    # Determine path based on option
    if len(sys.argv) >= 3:
        option = sys.argv[2]
        if option == '--path':
            if len(sys.argv) < 4:
                print("❌ Error: --path requires a path argument")
                sys.exit(1)
            path = sys.argv[3]
        elif option == '--local':
            path = os.path.join(os.getcwd(), '.opencode', 'skill')
        elif option == '--global':
            path = os.path.expanduser('~/.config/opencode/skill')
        else:
            print(f"❌ Error: Unknown option '{option}'. Use --path, --local, or --global.")
            sys.exit(1)
    else:
        # Default to global if no option specified
        path = os.path.expanduser('~/.config/opencode/skill')

    print(f"🚀 Initializing skill: {skill_name}")
    print(f"   Location: {path}")
    print()

    result = init_skill(skill_name, path)

    if result:
        sys.exit(0)
    else:
        sys.exit(1)


if __name__ == "__main__":
    main()
