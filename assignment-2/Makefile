$(if $(shell command -v cargo 2> /dev/null), $(info Found cargo), $(error rust not found. Please install cargo package manager with command "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"))

build:
	cargo build --release 
	cp target/release/mac .

dev: clean build
	sudo chown root:root ./mac
	sudo chmod 6755 ./mac

zip:
	zip assignment-2.zip src/* Cargo.* Makefile README

clean:
	sudo rm -f ./mac *.log