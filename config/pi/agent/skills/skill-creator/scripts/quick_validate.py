#!/usr/bin/env python3
"""
Quick validation script for OpenCode skills

Validates skill structure against OpenCode requirements:
- YAML frontmatter with required fields
- Skill naming conventions (1-64 chars, lowercase alphanumeric + hyphens)
- Description length and content rules
- Required files exist
"""

import sys
import re
import yaml
from pathlib import Path


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


def validate_description(description):
    """
    Validate skill description against OpenCode rules.
    
    Rules:
    - Must be a string
    - 1-1024 characters
    - Cannot contain angle brackets (< or >)
    """
    if not isinstance(description, str):
        return False, f"Description must be a string, got {type(description).__name__}"
    
    description = description.strip()
    
    if not description:
        return False, "Description cannot be empty"
    
    if len(description) > 1024:
        return False, f"Description is too long ({len(description)} characters). Maximum is 1024 characters."
    
    # Check for angle brackets (not allowed)
    if '<' in description or '>' in description:
        return False, "Description cannot contain angle brackets (< or >)"
    
    return True, "Valid description"


def validate_frontmatter(frontmatter):
    """
    Validate YAML frontmatter against OpenCode requirements.
    
    Required fields:
    - name (string)
    - description (string)
    
    Optional fields:
    - license (string)
    - compatibility (string, should be "opencode")
    - metadata (dict)
    
    Unknown fields are allowed but ignored.
    """
    if not isinstance(frontmatter, dict):
        return False, "Frontmatter must be a YAML dictionary"
    
    # Check required fields
    if 'name' not in frontmatter:
        return False, "Missing required field: 'name'"
    
    if 'description' not in frontmatter:
        return False, "Missing required field: 'description'"
    
    # Validate name
    name = frontmatter.get('name')
    if not isinstance(name, str):
        return False, f"'name' must be a string, got {type(name).__name__}"
    
    name_valid, name_message = validate_skill_name(name.strip())
    if not name_valid:
        return False, f"Invalid 'name': {name_message}"
    
    # Validate description
    description = frontmatter.get('description')
    desc_valid, desc_message = validate_description(description)
    if not desc_valid:
        return False, f"Invalid 'description': {desc_message}"
    
    # Validate optional fields if present
    if 'license' in frontmatter and not isinstance(frontmatter['license'], str):
        return False, f"'license' must be a string, got {type(frontmatter['license']).__name__}"
    
    if 'compatibility' in frontmatter:
        compat = frontmatter['compatibility']
        if not isinstance(compat, str):
            return False, f"'compatibility' must be a string, got {type(compat).__name__}"
    
    if 'metadata' in frontmatter and not isinstance(frontmatter['metadata'], dict):
        return False, f"'metadata' must be a dictionary, got {type(frontmatter['metadata']).__name__}"
    
    return True, "Valid frontmatter"


def validate_skill_structure(skill_path):
    """
    Validate the overall skill structure.
    
    Checks:
    - Skill directory exists
    - SKILL.md file exists
    - YAML frontmatter is valid
    - Skill name matches directory name
    """
    skill_path = Path(skill_path)
    
    # Check skill directory exists
    if not skill_path.exists():
        return False, f"Skill directory not found: {skill_path}"
    
    if not skill_path.is_dir():
        return False, f"Path is not a directory: {skill_path}"
    
    # Check SKILL.md exists
    skill_md = skill_path / 'SKILL.md'
    if not skill_md.exists():
        return False, "SKILL.md not found in skill directory"
    
    # Read and validate frontmatter
    content = skill_md.read_text()
    if not content.startswith('---'):
        return False, "SKILL.md must start with YAML frontmatter (---)"
    
    # Extract frontmatter
    match = re.match(r'^---\n(.*?)\n---', content, re.DOTALL)
    if not match:
        return False, "Invalid frontmatter format (must be enclosed in ---)"
    
    frontmatter_text = match.group(1)
    
    # Parse YAML frontmatter
    try:
        frontmatter = yaml.safe_load(frontmatter_text)
    except yaml.YAMLError as e:
        return False, f"Invalid YAML in frontmatter: {e}"
    
    # Validate frontmatter content
    valid, message = validate_frontmatter(frontmatter)
    if not valid:
        return False, message
    
    # Check skill name matches directory name
    skill_name = frontmatter.get('name', '').strip()
    if skill_name != skill_path.name:
        return False, f"Skill name '{skill_name}' does not match directory name '{skill_path.name}'"
    
    return True, f"Valid skill structure: {skill_name}"


def validate_skill(skill_path):
    """
    Comprehensive skill validation.
    
    This is the main entry point that performs all validation checks.
    
    Args:
        skill_path: Path to the skill folder
        
    Returns:
        Tuple of (is_valid: bool, message: str)
    """
    # Validate structure
    valid, message = validate_skill_structure(skill_path)
    if not valid:
        return False, message
    
    return True, message


def main():
    if len(sys.argv) != 2:
        print("Usage: python quick_validate.py <skill_directory>")
        print("\nValidates OpenCode skill structure:")
        print("  - YAML frontmatter format and required fields")
        print("  - Skill naming conventions (1-64 chars, lowercase alphanumeric + hyphens)")
        print("  - Description length and content rules")
        print("  - Required SKILL.md file exists")
        print("  - Skill name matches directory name")
        sys.exit(1)
    
    skill_path = sys.argv[1]
    
    print(f"🔍 Validating skill: {skill_path}")
    print()
    
    valid, message = validate_skill(skill_path)
    
    if valid:
        print(f"✅ {message}")
        sys.exit(0)
    else:
        print(f"❌ {message}")
        sys.exit(1)


if __name__ == "__main__":
    main()
