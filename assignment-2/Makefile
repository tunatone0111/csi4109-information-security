build:
	cargo build --release 
	cp target/release/mac .

dev: clean build
	sudo chown root:root ./mac
	sudo chmod 6755 ./mac

clean:
	sudo rm -f ./mac *.log