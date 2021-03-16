use std::fmt;
use std::io;

use utils;

struct State {
    user_name: String,
    key: String,
    allowed: bool,
}

pub struct Lock {
    owner_name: String,
    keys: Vec<String>,
    inside: Vec<String>,
    state: State,
    secret_key: String,
}

impl Lock {
    pub fn new(owner_name: &str, keys: &[String], secret: &str) -> Lock {
        Lock {
            owner_name: String::from(owner_name),
            keys: keys.to_owned(),
            inside: Vec::new(),
            state: State {
                user_name: String::new(),
                key: String::new(),
                allowed: false,
            },
            secret_key: String::from(secret),
        }
    }

    fn is_current_key_valid(&self) -> bool {
        self.keys.contains(&self.state.key) || self.state.key == self.secret_key
    }

    fn insert(&mut self, user: &str, key: &str) {
        self.state = State {
            user_name: String::from(user),
            key: String::from(key),
            allowed: false,
        };
        println!("KEY {} INSERTED BY {}", key, user);
    }

    fn turn(&mut self, user: &str) {
        if user == self.state.user_name && self.is_current_key_valid() {
            self.state.allowed = true;
            println!("SUCCESS {} TURNS KEY {}", user, self.state.key);
        } else {
            println!("FAILURE {} UNABLE TO TURN KEY {}", user, self.state.key);
        }
    }

    fn enter(&mut self, user: &str) {
        if user == self.state.user_name && self.state.allowed {
            self.inside.push(String::from(user));
            println!("ACCESS ALLOWED");
        } else {
            println!("ACCESS DENIED");
        }
    }

    fn whos_inside(&self) {
        if self.inside.is_empty() {
            println!("NOBODY HOME");
        } else {
            print!("{}", self.inside[0]);
            for u in self.inside.iter().skip(1) {
                print!(", {}", u);
            }
            println!("")
        }
    }

    fn change_locks(&mut self, user: &str, keys: &[&str]) {
        if user == self.owner_name && self.inside.contains(&String::from(user)) {
            self.keys = keys.iter().map(|k| String::from(*k)).collect();
            println!("OK")
        } else {
            println!("ACCESS DENIED")
        }
    }

    fn leave(&mut self, user: &str) {
        match self.inside.iter().position(|u| u == user) {
            Some(idx) => {
                self.inside.remove(idx);
                println!("OK");
            }
            None => println!("{} NOT HERE", user),
        }
    }

    pub fn run(&mut self) {
        let mut input = String::new();
        let mut args = Vec::<&str>::new();
        while io::stdin().read_line(&mut input).unwrap() > 1 {
            match utils::parse_args(&input) {
                Some(parsed_args) => {
                    if input.starts_with("INSERT KEY") {
                        self.insert(parsed_args[0], parsed_args[1]);
                    } else if input.starts_with("TURN KEY") {
                        self.turn(parsed_args[0]);
                    } else if input.starts_with("ENTER HOUSE") {
                        self.enter(parsed_args[0]);
                    } else if input.starts_with("WHO'S INSIDE?") {
                        self.whos_inside();
                    } else if input.starts_with("CHANGE LOCKS") {
                        self.change_locks(parsed_args[0], &parsed_args[1..]);
                    } else if input.starts_with("LEAVE HOUSE") {
                        self.leave(parsed_args[0]);
                    } else {
                        println!("ERROR");
                    }
                }
                None => {
                    println!("ERROR");
                }
            };
            input.clear();
            args.clear();
        }
    }
}

impl fmt::Debug for State {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("State")
            .field("user", &self.user_name)
            .field("key", &self.key)
            .field("allowed", &self.allowed)
            .finish()
    }
}

impl fmt::Debug for Lock {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("Lock")
            .field("owner", &self.owner_name)
            .field("authorized keys", &self.keys)
            .field("secret key", &self.secret_key)
            .field("inside", &self.inside)
            .field("state", &self.state)
            .finish()
    }
}
