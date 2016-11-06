
TARGET=thing.hex

$(TARGET): thing.asm img.inc
	gpasm -w 1 thing.asm

img.inc: convimg/imgconv
	./convimg/imgconv convimg/img.png > img.inc

convimg/imgconv: convimg
	make -C convimg


flash: $(TARGET)
	sudo mount /dev/sdd /mnt
	sudo cp $(TARGET) /mnt
	sudo umount /mnt

