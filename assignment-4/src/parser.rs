extern crate clap;
use clap::{App, Arg, SubCommand};

pub fn get_parser() -> App<'static, 'static> {
    App::new("Signtool")
        .version("1.0")
        .subcommand(
            SubCommand::with_name("sign")
                .arg(
                    Arg::with_name("executable")
                        .help("path to executable")
                        .short("e")
                        .required(true)
                        .takes_value(true),
                )
                .arg(
                    Arg::with_name("key")
                        .help("path to private_key.pem")
                        .short("k")
                        .required(true)
                        .takes_value(true),
                )
                .arg(
                    Arg::with_name("outdir")
                        .help("path to signed executable")
                        .short("o")
                        .required(true)
                        .takes_value(true),
                ),
        )
        .subcommand(
            SubCommand::with_name("verify")
                .arg(
                    Arg::with_name("executable")
                        .help("path to signed executable")
                        .short("e")
                        .required(true)
                        .takes_value(true),
                )
                .arg(
                    Arg::with_name("key")
                        .help("path to public_key.pem")
                        .short("k")
                        .required(true)
                        .takes_value(true),
                ),
        )
}
