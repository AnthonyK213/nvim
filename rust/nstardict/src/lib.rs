use ex_util::{str_buf_to_string, str_try_parse};
use rust_stardict::Dictionaries;
use std::ffi::{c_char, CString};

#[no_mangle]
pub extern "C" fn nstardict_find_dicts(dict_dir: *const c_char) -> Box<Dictionaries> {
    Box::new(Dictionaries::new(&str_buf_to_string(dict_dir).unwrap()))
}

#[no_mangle]
pub extern "C" fn nstardict_search(
    dicts: Option<&Dictionaries>,
    word: *const c_char,
) -> *mut c_char {
    let _dicts = match dicts {
        Some(d) => d,
        None => return std::ptr::null_mut(),
    };
    let _word = str_try_parse!(word, std::ptr::null_mut());
    let result = _dicts.search_word_into_json(&_word);
    if let Ok(res) = CString::new(result) {
        res.into_raw()
    } else {
        std::ptr::null_mut()
    }
}

#[no_mangle]
pub extern "C" fn nstardict_drop(_: Option<Box<Dictionaries>>) {}
