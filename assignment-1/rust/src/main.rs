use std::env;

mod lock;
mod utils;

fn main() {
    let cli_args: Vec<String> = env::args().collect();
    if cli_args.len() < 3 {
        panic!("Invalid command! Usage: ./secure_house <owner_name> <key_1> <key_2> ... <key_n>")
    }
    let mut lock = lock::Lock::new(&cli_args[1], &cli_args[2..], "FIREFIGHTER_SECRET_KEY");
    lock.run();
}
