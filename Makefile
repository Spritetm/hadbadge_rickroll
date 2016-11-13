
TARGET=thing.hex
TARGET2=main.hex

DEV=/dev/sdd

$(TARGET): thing.asm mov.inc
	gpasm -w 1 thing.asm

$(TARGET2): main.asm music.inc
	gpasm -w 1 main.asm

img.inc: convimg/imgconv
	./convimg/imgconv convimg/img.png > img.inc

convimg/imgconv: convimg
	make -C convimg


flash: $(TARGET)
	sudo mount $(DEV) /mnt
	sudo cp $(TARGET) /mnt
	sudo umount /mnt


flashmain: $(TARGET2)
	sudo mount $(DEV) /mnt
	sudo cp $(TARGET2) /mnt
	sudo umount /mnt

