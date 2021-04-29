extern crate clap;
use clap::{App, Arg, SubCommand};

fn main() {
    let args = vec![
        Arg::with_name("executable")
            .short("e")
            .required(true)
            .takes_value(true),
        Arg::with_name("key")
            .short("k")
            .required(true)
            .takes_value(true),
    ];

    let matches = App::new("Signtool")
        .version("1.0")
        .subcommand(SubCommand::with_name("sign").args(&args))
        .subcommand(SubCommand::with_name("verify").args(&args))
        .get_matches();

    if let Some(matches) = matches.subcommand_matches("sign") {
        let executable = matches.value_of("executable").unwrap();
        let key = matches.value_of("key").unwrap();

        println!("executable: {}, key: {}", executable, key);
    }

    if let Some(matches) = matches.subcommand_matches("verify") {
        let executable = matches.value_of("executable").unwrap();
        let key = matches.value_of("key").unwrap();

        println!("executable: {}, key: {}", executable, key);
    }
}
