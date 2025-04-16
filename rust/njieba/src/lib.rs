use _ffi_util::str_util;
use jieba_rs::{Jieba, TokenizeMode};
use std::ffi::{c_char, c_int};

const ERR_NO_ERRORS: i32 = 0;
const ERR_FAILED: i32 = 1;
const ERR_INVALID_JB_PTR: i32 = 2;

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
    let jb_obj = match jieba {
        Some(v) => v,
        None => return ERR_INVALID_JB_PTR,
    };

    let sentence = match str_util::char_buf_to_string(line) {
        Ok(s) => s,
        Err(_) => return ERR_FAILED,
    };

    let tokens = jb_obj.tokenize(&sentence, TokenizeMode::Default, false);

    for token in tokens {
        let tk_start: c_int = match token.start.try_into() {
            Ok(v) => v,
            Err(_) => return ERR_FAILED,
        };

        let tk_end: c_int = match token.end.try_into() {
            Ok(v) => v,
            Err(_) => return ERR_FAILED,
        };

        if tk_start <= pos && tk_end > pos {
            unsafe {
                start.write(tk_start);
                end.write(tk_end);
            }

            return ERR_NO_ERRORS;
        }
    }

    ERR_FAILED
}

#[no_mangle]
pub extern "C" fn njieba_drop(_: Option<Box<Jieba>>) {}
