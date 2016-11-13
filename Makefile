
TARGET=thing.hex
TARGET2=main.hex


$(TARGET): thing.asm mov.inc
	gpasm -w 1 thing.asm

$(TARGET2): main.asm music.inc
	gpasm -w 1 main.asm

img.inc: convimg/imgconv
	./convimg/imgconv convimg/img.png > img.inc

convimg/imgconv: convimg
	make -C convimg


flash: $(TARGET)
	sudo mount /dev/sdd /mnt
	sudo cp $(TARGET) /mnt
	sudo umount /mnt


flashmain: $(TARGET2)
	sudo mount /dev/sdd /mnt
	sudo cp $(TARGET2) /mnt
	sudo umount /mnt

orig: demo2.hex
	sudo mount /dev/sdd /mnt
	sudo cp demo2.hex /mnt
	sudo umount /mnt
