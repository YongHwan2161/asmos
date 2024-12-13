# Makefile for MyOS (Protected Mode)

# Tools
ASM=nasm
QEMU=qemu-system-x86_64

# Directories
SRC_DIR=src
BUILD_DIR=build

# Files
BOOTLOADER=$(SRC_DIR)/boot.asm
KERNEL=$(SRC_DIR)/kernel.asm
BOOTLOADER_BIN=$(BUILD_DIR)/boot.bin
KERNEL_BIN=$(BUILD_DIR)/kernel.bin
OS_IMAGE=$(BUILD_DIR)/os.img
DISK_IMAGE=$(BUILD_DIR)/disk.img

# Flags
ASM_FLAGS=-f bin -I $(SRC_DIR)
QEMU_FLAGS=-drive format=raw,file=$(DISK_IMAGE),if=ide,index=0 \
          -vga std \
          -display gtk \
          -device isa-debug-exit,iobase=0xf4,iosize=0x04 \
          -device qemu-xhci,id=xhci \
          -device usb-tablet \
          -monitor stdio \
          -no-reboot \
          -no-shutdown

all: $(DISK_IMAGE)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BOOTLOADER_BIN): $(BOOTLOADER) | $(BUILD_DIR)
	$(ASM) $(ASM_FLAGS) $(BOOTLOADER) -o $(BOOTLOADER_BIN)

$(KERNEL_BIN): $(KERNEL) | $(BUILD_DIR)
	$(ASM) $(ASM_FLAGS) $(KERNEL) -o $(KERNEL_BIN)

$(DISK_IMAGE): $(BOOTLOADER_BIN) $(KERNEL_BIN) | $(BUILD_DIR)
	# Create disk image with proper size
	dd if=/dev/zero of=$(DISK_IMAGE) bs=512 count=69000    # 
	
	# Write bootloader to first sector
	dd if=$(BOOTLOADER_BIN) of=$(DISK_IMAGE) conv=notrunc
	
	# Write kernel starting at sector 1
	dd if=$(KERNEL_BIN) of=$(DISK_IMAGE) seek=1 conv=notrunc
	
	# Initialize remaining space as FAT32
	@echo "Creating FAT32 filesystem in remaining space..."
	@ START_SECTOR=2048 && \
	SIZE_IN_SECTORS=$$(( 69000 - $$START_SECTOR )) && \
	dd if=/dev/zero of=$(DISK_IMAGE) bs=512 seek=$$START_SECTOR count=$$SIZE_IN_SECTORS && \
	LOOP_DEVICE=$$(sudo losetup --find --show --offset $$((START_SECTOR * 512)) $(DISK_IMAGE)) && \
	sudo mkfs.fat -F 32 -n "MYOS" $$LOOP_DEVICE && \
	sudo losetup -d $$LOOP_DEVICE || exit 1
run: $(DISK_IMAGE)
	$(QEMU) $(QEMU_FLAGS)

debug: $(OS_IMAGE)
	$(QEMU) $(QEMU_FLAGS) -s -S

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all run debug clean