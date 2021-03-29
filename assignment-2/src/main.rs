use nix::unistd::{getgid, getuid, setegid, seteuid};
use std::fs::OpenOptions;
use std::os::unix::fs::OpenOptionsExt;
use std::{collections::HashMap, env, fs, io::Write, process::exit};
use users::{get_current_uid, get_user_by_uid};

fn main() {
    let cli_args: Vec<String> = env::args().collect();
    if (cli_args.len() < 3) || (cli_args[1] != "read") {
        panic!("Invalid command! Usage: ./mac read <document file>");
    }
    let subcommand = &cli_args[1];
    let filename = &cli_args[2];

    let user = get_user_by_uid(get_current_uid()).unwrap();
    let username = user.name().to_str().unwrap();

    // get mac.policy
    let perms_raw = fs::read_to_string("mac.policy").expect("Unexpected Error.");
    let mut perms: HashMap<&str, i8> = HashMap::new();
    for perm_raw in perms_raw.lines() {
        let kv = perm_raw.split(":").collect::<Vec<&str>>();
        perms.insert(
            kv[0],
            match kv[1].as_ref() {
                "UNCLASSIFIED" => 0,
                "CONFIDENTIAL" => 1,
                "SECRET" => 2,
                "TOP_SECRET" => 3,
                _ => -1,
            },
        );
    }

    if !perms.contains_key(&username) {
        println!("ACCESS DENIED");
        exit(0);
    }

    let user_perm = *perms.get(&username).unwrap();

    let contents = match filename.as_ref() {
        "unclassified.data" => fs::read_to_string(filename).unwrap(),
        "confidential.data" => match user_perm >= 1 {
            true => fs::read_to_string(filename).unwrap(),
            false => String::from("ACCESS DENIED"),
        },
        "secret.data" => match user_perm >= 2 {
            true => fs::read_to_string(filename).unwrap(),
            false => String::from("ACCESS DENIED"),
        },
        "top_secret.data" => match user_perm >= 3 {
            true => fs::read_to_string(filename).unwrap(),
            false => String::from("ACCESS DENIED"),
        },
        _ => String::from("ACCESS DENIED"),
    };

    // drop root permission
    seteuid(getuid()).unwrap();
    setegid(getgid()).unwrap();

    // logging and printing
    let mut options = OpenOptions::new();
    options.mode(0o640).append(true).create(true);
    let log_filename = format!("{}.log", username);
    let mut log_file = options.open(log_filename).unwrap();

    writeln!(&mut log_file, "{} {}", subcommand, filename).unwrap();
    println!("{}", &contents);
}
