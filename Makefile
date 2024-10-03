SHELL=/bin/bash

CDJ3Kv000.UPD: LOOP=$(shell sudo losetup -f)
CDJ3Kv000.UPD CDJ3Kv000.UPD.crc32: CDJ3K-RK3399.iso src/* src/.*
	genisoimage -R -J -input-charset utf-8 --graft-points -o CDJ3Kv000.UPD images/CDJ3K-RK3399.iso=CDJ3K-RK3399.iso src/* src/.*
	isoinfo -R -l -i CDJ3Kv000.UPD
#   Make room for LUKS header
	dd if=/dev/zero bs=32M count=1 >> CDJ3Kv000.UPD
	sudo losetup ${LOOP} CDJ3Kv000.UPD
	sudo cryptsetup reencrypt \
		--batch-mode \
		--encrypt \
		--reduce-device-size 32M \
		--type luks1 \
		--cipher aes-xts-plain64 \
		--key-size 512 \
		--key-file aes256.key \
		$(LOOP) cdj_firmware
	sudo losetup -d $(LOOP)
#   Calculate CRC before writing magic trailer
	./crc32.py CDJ3Kv000.UPD > CDJ3Kv000.UPD.crc32
	echo -n -e 'XDJ-RR0.00\x00' >> CDJ3Kv000.UPD
	cat CDJ3Kv000.UPD.crc32 >> CDJ3Kv000.UPD

CDJ3K-RK3399.iso: src/* src/.*
	genisoimage -R -J -input-charset utf-8 -o CDJ3K-RK3399.iso src/* src/.*
	isoinfo -R -l -i CDJ3K-RK3399.iso
