link: build
	ln -sf target/debug/signtool . 
	chmod +x signtool

build:
	cargo build

key:
	rm *.pem
	openssl genrsa -out private_key.pem 2048
	openssl rsa -in private_key.pem -out public_key.pem -pubout

zip:
	zip assignment-4.zip -r Makefile src Cargo.* bypass-licensechk-signed licensechk-signed README