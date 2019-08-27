DRIVERS = retro-drivers/x86.retro \
          retro-drivers/vga-textmode.retro \
          retro-drivers/keyboard.retro \

default: assemble update extend combine

assemble:
	sh build.sh

update:
	curl http://forth.works/live/ngaImage -o ngaImage

extend:
	retro-extend ngaImage $(DRIVERS) listener.retro

combine:
	cat kernel-x86 ngaImage > retro-native
