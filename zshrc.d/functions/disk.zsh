mnt_img() {
    artifact_file="$1"
    
    if [ $# -ne 1 ]; then
      echo "usage: $0 disk.img"
      exit 1
    fi
    
    if [ ! -f "$artifact_file" ] || ! parted -m "$artifact_file" print >/dev/null 2>&1; then
      >&2 echo "error: $file doesn't exist or is not a valid image file"
      exit 1
    fi
    
    rootfs="/mnt/disk"
    boot_dir="$rootfs/boot"
    
    LOOP_DEV=$(sudo losetup --partscan --show --find "$artifact_file")
    BOOT_DEV="$LOOP_DEV"p1
    ROOT_DEV="$LOOP_DEV"p2
    
    sudo mkdir -p "$rootfs"
    sudo mount --make-private "$ROOT_DEV" "$rootfs"
    sudo mkdir -p "$boot_dir"
    sudo mount --make-private "$BOOT_DEV" "$boot_dir"
}

