use ex_util::{str_buf_to_string, str_try_parse};
use jieba_rs::{Jieba, TokenizeMode};
use std::ffi::{c_char, c_int};

#[no_mangle]
pub extern "C" fn njieba_new() -> Box<Jieba> {
    Box::new(Jieba::new())
}

#[no_mangle]
pub extern "C" fn njieba_pos(
    jieba: Option<&Jieba>,
    line: *const c_char,
    pos: c_int,
    start: *mut c_int,
    end: *mut c_int,
) -> c_int {
    let jb = match jieba {
        Some(v) => v,
        None => return 4,
    };
    let sentence = str_try_parse!(line, 1);
    let tokens = jb.tokenize(&sentence, TokenizeMode::Default, false);
    for token in tokens {
        let tk_start: c_int = match token.start.try_into() {
            Ok(v) => v,
            Err(_) => return 2,
        };
        let tk_end: c_int = match token.end.try_into() {
            Ok(v) => v,
            Err(_) => return 2,
        };
        if tk_start <= pos && tk_end > pos {
            unsafe {
                start.write(tk_start);
                end.write(tk_end);
            }
            return 0;
        }
    }
    3
}

#[no_mangle]
pub extern "C" fn njieba_drop(_: Option<Box<Jieba>>) {}
