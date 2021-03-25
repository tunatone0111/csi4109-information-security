use std::env;

fn main() {
    let cli_args: Vec<String> = env::args().collect();
    if (cli_args.len() < 3) || (cli_args[1] != "read") {
        panic!("Invalid command! Usage: ./mac read <document file>");
    }
    println!("user: {}, group: {}", libc::getuid(), libc::getgid());
    println!("command: {}, params: {:?}", cli_args[1], &cli_args[2..]);
}
