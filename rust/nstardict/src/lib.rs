use rust_stardict::stardict;
use std::ffi::{c_char, CStr, CString};

macro_rules! string_parse {
    ($c_buf: expr, $code: expr) => {
        match c_buf_to_string($c_buf) {
            Ok(v) => v,
            Err(_) => return $code,
        }
    };
}

fn c_buf_to_string(c_buf: *const c_char) -> Result<String, std::str::Utf8Error> {
    Ok(unsafe { CStr::from_ptr(c_buf) }.to_str()?.to_owned())
}

#[no_mangle]
pub extern "C" fn nstardict(dict_dir: *const c_char, word: *const c_char) -> *mut c_char {
    let _dict_dir = string_parse!(dict_dir, std::ptr::null_mut());
    let _word = string_parse!(word, std::ptr::null_mut());
    let result = stardict(_dict_dir, _word);
    if let Ok(res) = CString::new(result) {
        res.into_raw()
    } else {
        std::ptr::null_mut()
    }
}

#[no_mangle]
pub unsafe extern "C" fn nstardict_string_free(s: *mut c_char) {
    if s.is_null() {
        return;
    }
    drop(CString::from_raw(s));
}
