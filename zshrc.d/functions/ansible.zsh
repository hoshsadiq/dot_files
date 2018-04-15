vault_encrypt() {
    file="$1"

    if [ -z "$file" ]; then
        echo "Usage:"
        echo "  $0 /path/to/file"
        return 1
    fi

    if [ ! -f "$file" ]; then
        echo "file $file does not exist"
        return 1
    fi

    if [ -f "$file.enc" ]; then
      encryptedData="$(ansible-vault decrypt --vault-password-file=~/.vault-credentials --output - "$file.enc")"
      unencryptedData="$(cat "$file")"

      if cmp -s <(echo $encryptedData) <(echo $unencryptedData); then
        echo "Encrypted file is identical to unencrypted file... skipping"
        return 1
      fi
    fi

    ansible-vault encrypt --vault-password-file=~/.vault-credentials --output "$file.enc" "$file"
}

vault_decrypt() {
    file="$1"

    if [ -z "$file" ]; then
        echo "Usage:"
        echo "  $0 /path/to/file"
        return 1
    fi

    if [ ! -f "$file.enc" ]; then
        echo "file $file.enc does not exist"
        return 1
    fi

    ansible-vault decrypt --vault-password-file=~/.vault-credentials --output "$file" "$file.enc"
}
