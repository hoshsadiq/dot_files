def colorize(color; text):
  if env.COLOR == "true" then
    if color == "key" then "\u001b[36m\(text)\u001b[0m"      # Cyan for keys
    elif color == "string" then "\u001b[32m\(text)\u001b[0m" # Green for strings
    elif color == "number" then "\u001b[33m\(text)\u001b[0m" # Yellow for numbers
    elif color == "bool" then "\u001b[35m\(text)\u001b[0m"   # Magenta for booleans
    elif color == "null" then "\u001b[31m\(text)\u001b[0m"   # Red for null
    elif color == "type" then "\u001b[90m\(text)\u001b[0m"   # Gray for type indicators
    elif color == "path" then "\u001b[1;36m\(text)\u001b[0m" # Bold cyan for paths
    else text
    end
  else
    text
  end;

# Get the type information for display
def get_type_info(val):
  if env.SHOW_TYPES == "true" then
    if val | type == "object" then "object"
    elif val | type == "array" then "array"
    elif val | type == "string" then "str"
    elif val | type == "number" then "num"
    elif val | type == "boolean" then "bool"
    elif val | type == "null" then "null"
    else ""
    end
  else
    ""
  end;

# Function to get unique types from an array
def get_array_types:
  if length == 0 then
    "empty"
  else
    reduce .[] as $item ([];
      . + [$item | type]
    ) | unique | join(" | ")
  end;

# Function to get unique types from an object's values
def get_object_value_types:
  if length == 0 then
    "empty"
  else
    [to_entries[].value | type] | unique | join(" | ")
  end;

# Format key with size indicator for objects
def format_object_key(key; val):
  if env.SHOW_SIZES == "true" then
    "\(colorize("key"; key)){\(val | length)}"
  else
    colorize("key"; key)
  end;

# Format key with size indicator for arrays
def format_array_key(key; val):
  if env.SHOW_SIZES == "true" then
    "\(colorize("key"; key))[\(val | length)]"
  else
    colorize("key"; key)
  end;

# Format array index with a size indicator for its value if needed
def format_array_index(index; val):
  if val | type == "array" and env.SHOW_SIZES == "true" then
    "\(colorize("key"; index))[\(val | length)]"
  elif val | type == "object" and env.SHOW_SIZES == "true" then
    "\(colorize("key"; index)){\(val | length)}"
  else
    colorize("key"; index)
  end;

# Get type indicator for array values
def get_array_type_indicator(val):
  if env.SHOW_TYPES == "true" then
    if val | length > 0 then
      val | get_array_types
    else
      "empty"
    end
  else
    ""
  end;

# Get type indicator for object values
def get_object_type_indicator(val):
  if env.SHOW_TYPES == "true" then
    if val | length > 0 then
      val | get_object_value_types
    else
      "empty"
    end
  else
    ""
  end;

def format_value:
  if type == "string" then colorize("string"; "\"\(.)\"")
  elif type == "number" then colorize("number"; "\(.)")
  elif type == "boolean" then colorize("bool"; "\(.)")
  elif type == "null" then colorize("null"; "null")
  else "."
  end;

# Create and extract paths from the focus path string
def get_focus_path_parts:
  if env.FOCUS_PATH and env.FOCUS_PATH != "" then
    env.FOCUS_PATH | split(".")
  else
    []
  end;

# Create string representation of a path array
def path_to_string(path_parts):
  path_parts | join(".")
;

# Check if path matches or is a child of the focus path
def is_path_match(path_str):
  env.FOCUS_PATH as $focus_path
  | if $focus_path == path_str then
      true
    elif path_str | startswith($focus_path + ".") then
      true
    else
      false
    end
;

# Check if path is a parent of the focus path
def is_path_parent(path_str):
  env.FOCUS_PATH as $focus_path
  | ($focus_path | startswith(path_str + "."))
;

# Check if this path should be shown based on the focus path
def should_show_path(path_parts):
  if env.FOCUS_PATH and env.FOCUS_PATH != "" then
    path_to_string(path_parts) as $path_str
    | is_path_match($path_str) or is_path_parent($path_str)
  else
    true
  end;

# Main recursive tree walking function
def walk(prefix; is_last; path_parts):
  . as $in
  | if should_show_path(path_parts) then
      if type == "object" then
        if length == 0 and env.COLLAPSE_EMPTY == "true" then
          "\(prefix)└── " + colorize("type"; "{0} empty")
        else
          to_entries
          | sort_by(.key)
          | . as $entries
          | length as $len
          | range(0; $len) as $i
          | $entries[$i] as $entry
          | ($i == $len - 1) as $is_last_entry
          | $entry.key as $key
          | $entry.value as $value
          | ($entry.key | tostring) as $key_str
          | (path_parts + [$key_str]) as $new_path_parts
          | if should_show_path($new_path_parts) then
              (
                # Format based on value type
                if $value | type == "object" then
                  if $is_last_entry then
                    "\(prefix)└── \(format_object_key($key; $value)) \(colorize("type"; get_object_type_indicator($value)))"
                  else
                    "\(prefix)├── \(format_object_key($key; $value)) \(colorize("type"; get_object_type_indicator($value)))"
                  end
                elif $value | type == "array" then
                  if $is_last_entry then
                    "\(prefix)└── \(format_array_key($key; $value)) \(colorize("type"; get_array_type_indicator($value)))"
                  else
                    "\(prefix)├── \(format_array_key($key; $value)) \(colorize("type"; get_array_type_indicator($value)))"
                  end
                else
                  if $is_last_entry then
                    "\(prefix)└── \(colorize("key"; $key)) \(colorize("type"; get_type_info($value)))"
                  else
                    "\(prefix)├── \(colorize("key"; $key)) \(colorize("type"; get_type_info($value)))"
                  end
                end,
                (
                  $value | walk(
                    if $is_last_entry then
                      "\(prefix)    "
                    else
                      "\(prefix)│   "
                    end;
                    $is_last_entry;
                    $new_path_parts
                  )
                )
              )
            else
              empty
            end
        end
      elif type == "array" then
        if length == 0 and env.COLLAPSE_EMPTY == "true" then
          empty
        elif length > 0 then
          to_entries
          | . as $entries
          | length as $len
          | range(0; $len) as $i
          | $entries[$i] as $entry
          | ($i == $len - 1) as $is_last_entry
          | ($entry.key | tostring) as $key_str
          | (path_parts + [$key_str]) as $new_path_parts
          | if should_show_path($new_path_parts) then
              (
                if $is_last_entry then
                  "\(prefix)└── \(format_array_index($entry.key; $entry.value)) \(colorize("type"; get_type_info($entry.value)))"
                else
                  "\(prefix)├── \(format_array_index($entry.key; $entry.value)) \(colorize("type"; get_type_info($entry.value)))"
                end,
                (
                  $entry.value | walk(
                    if $is_last_entry then
                      "\(prefix)    "
                    else
                      "\(prefix)│   "
                    end;
                    $is_last_entry;
                    $new_path_parts
                  )
                )
              )
            else
              empty
            end
        else
          empty
        end
      elif type == "string" or type == "number" or type == "boolean" or type == "null" then
        "\(prefix)└── \(format_value)"
      else
        "\(prefix)└── \(.)"
      end
    else
      empty
    end;

def format_root_key(key; val):
  if val | type == "object" and env.SHOW_SIZES == "true" then
    "\(colorize("key"; key)){\(val | length)}/"
  elif val | type == "array" and env.SHOW_SIZES == "true" then
    "\(colorize("key"; key))[\(val | length)]/"
  else
    "\(colorize("key"; key))/"
  end;

def print_tree:
  # Process all root-level objects
  if type == "object" then
    to_entries
    | . as $entries
    | length as $len
    | range(0; $len) as $i
    | $entries[$i] as $entry
    | ($i == $len - 1) as $is_last_entry
    | $entry.key as $key
    | [$key] as $path_parts
    | if should_show_path($path_parts) then
        (
          # Print the root key with a trailing slash and type info
          "\(format_root_key($key; $entry.value)) \(colorize("type"; get_type_info($entry.value)))",
          (
            $entry.value | walk(
              "";
              $is_last_entry;
              $path_parts
            )
          )
        )
      else
        empty
      end
  else
    # If the input is not an object, just print it directly
    walk(""; false; [])
  end;

# Display focus path as a header if specified
def print_focus_header:
  if env.FOCUS_PATH and env.FOCUS_PATH != "" then
    "Showing only paths under: \(colorize("path"; env.FOCUS_PATH))"
  else
    empty
  end;

# Usage:
# cat input.json | jq -f json-tree.jq
print_focus_header,
print_tree
