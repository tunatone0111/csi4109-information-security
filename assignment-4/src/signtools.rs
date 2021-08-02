extern crate elf;
extern crate openssl;

use std::fs;
use std::io::prelude::*;
use std::process::Command;

use elf::types::SHF_EXECINSTR;

use openssl::hash::MessageDigest;
use openssl::pkey::PKey;
use openssl::rsa::Rsa;
use openssl::sign::{Signer, Verifier};

fn is_executable(section: &elf::Section) -> bool {
    section.shdr.flags.0 & SHF_EXECINSTR.0 == SHF_EXECINSTR.0
}

pub fn sign(executable_path: &str, key_path: &str, out_dir: &str) -> &'static str {
    let executable = match elf::File::open_path(&executable_path) {
        Err(_) => return "INVALID_FILE",
        Ok(f) => f,
    };

    let priv_key = match fs::read_to_string(&key_path) {
        Err(_) => return "INVALID_KEY",
        Ok(dump) => match Rsa::private_key_from_pem(dump.as_bytes()) {
            Err(_) => return "INVALID_KEY",
            Ok(rsa) => PKey::from_rsa(rsa).unwrap(),
        },
    };
    let mut signer = Signer::new(MessageDigest::sha256(), &priv_key).unwrap();

    for scn in &executable.sections {
        if is_executable(&scn) {
            signer.update(&scn.data).unwrap();
        }
    }
    let signature = signer.sign_to_vec().unwrap();

    fs::File::create("signature-tmp")
        .unwrap()
        .write_all(&signature)
        .unwrap();

    Command::new("objcopy")
        .args(&["--add-section", ".signature=signature-tmp"])
        .args(&["--set-section-flags", ".signature=contents,readonly"])
        .arg(&executable_path)
        .arg(&out_dir)
        .output()
        .expect("Failed");

    return "OK";
}

pub fn verify(executable_path: &str, key_path: &str) -> &'static str {
    let executable = match elf::File::open_path(&executable_path) {
        Err(_) => return "INVALID_FILE",
        Ok(f) => f,
    };

    let signature = match executable.get_section(".signature") {
        None => return "NOT_SIGNED",
        Some(scn) => &scn.data,
    };

    let pub_key = match fs::read_to_string(&key_path) {
        Err(_) => return "INVALID_KEY",
        Ok(dump) => match Rsa::public_key_from_pem(dump.as_bytes()) {
            Err(_) => return "INVALID_KEY",
            Ok(rsa) => PKey::from_rsa(rsa).unwrap(),
        },
    };
    let mut verifier = Verifier::new(MessageDigest::sha256(), &pub_key).unwrap();

    for scn in &executable.sections {
        if is_executable(&scn) {
            verifier.update(&scn.data).unwrap();
        }
    }

    match verifier.verify(&signature).unwrap() {
        true => "OK",
        false => "NOT_OK",
    }
}
