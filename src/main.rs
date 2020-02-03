use getopts::{Options, Matches};
use std::env::args;

#[derive(Debug)]
enum Backend {
    Mastodon,
    Twitter,
    Imgur
}

fn usage(basename: &str, opts: Options) {
    let brief: String = format!("Usage: {} FILE [options]", basename);
    print!("{}", opts.usage(&brief));
}

fn cont(message: &str, file: Option<String>, backend: Backend) {
    println!("Message: {}", message);
    match file {
        Some(some) => println!("File: {}", some),
        None => println!("File: None")
    }
    println!("Backend: {:?}", backend);
}

fn cli() {
    let args: Vec<String> = args().collect();
    let basename: String = args[0].clone();

    let mut opts: Options = Options::new();
    opts.optopt("f", "file", "include file in post", "FILE");
    opts.optflag("", "mastodon", "use Mastodon backend (default)");
    opts.optflag("", "twitter", "use Twitter backend");
    opts.optflag("", "imgur", "use Imgur backend");
    opts.optflag("h", "help", "print this help menu");

    let matches: Matches = match opts.parse(&args[1..]) {
        Ok(ok) => ok,
        Err(e) => panic!(e.to_string())
    };

    if matches.opt_present("h") {
        usage(&basename, opts);
        return;
    }

    let file: Option<String> = matches.opt_str("f");
    
    let message: String = if !matches.free.is_empty() {
        matches.free[0].clone()
    } else {
        usage(&basename, opts);
        return;
    };

    let backend: Backend = if matches.opt_present("mastodon") {
        Backend::Mastodon
    } else if matches.opt_present("twitter") {
        Backend::Twitter
    } else if matches.opt_present("imgur") {
        Backend::Imgur
    } else {
        Backend::Mastodon
    };

    cont(&message, file, backend)
}

fn main() {
    cli();
}
