use rust_stardict::stardict;
use std::ffi::{c_char, CString};
use ex_util::{str_try_parse, str_buf_to_string};

#[no_mangle]
pub extern "C" fn nstardict(dict_dir: *const c_char, word: *const c_char) -> *mut c_char {
    let _dict_dir = str_try_parse!(dict_dir, std::ptr::null_mut());
    let _word = str_try_parse!(word, std::ptr::null_mut());
    let result = stardict(_dict_dir, _word);
    if let Ok(res) = CString::new(result) {
        res.into_raw()
    } else {
        std::ptr::null_mut()
    }
}
