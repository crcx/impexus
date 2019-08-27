default: assemble update extend combine

assemble:
	sh build.sh

update:
	curl http://forth.works/live/ngaImage -o ngaImage

extend:

combine:
	cat kernel ngaImage > retro-native
