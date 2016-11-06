
TARGET=thing.hex

$(TARGET): thing.asm
	gpasm -w 1 $^




flash: $(TARGET)
	sudo mount /dev/sdd /mnt
	sudo cp $(TARGET) /mnt
	sudo umount /mnt

