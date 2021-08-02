mod parser;
mod signtools;
use signtools::{sign, verify};

fn main() {
    let matches = parser::get_parser().get_matches();

    if let Some(args) = matches.subcommand_matches("sign") {
        let executable_path = args.value_of("executable").unwrap();
        let key_path = args.value_of("key").unwrap();
        let out_dir = args.value_of("outdir").unwrap();
        println!("{}", sign(executable_path, key_path, out_dir));
    }

    if let Some(args) = matches.subcommand_matches("verify") {
        let executable_path = args.value_of("executable").unwrap();
        let key_path = args.value_of("key").unwrap();
        println!("{}", verify(executable_path, key_path));
    }
}
