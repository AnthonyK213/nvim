use _ffi_util::str_util;
use rust_stardict::Library;
use std::ffi::{c_char, CString};

#[no_mangle]
pub extern "C" fn nstardict_new_library(dict_dir: *const c_char) -> Box<Library> {
    Box::new(Library::new(&str_util::char_buf_to_string(dict_dir).unwrap()))
}

#[no_mangle]
pub extern "C" fn nstardict_consult(library: Option<&Library>, word: *const c_char) -> *mut c_char {
    let lib_obj = match library {
        Some(l) => l,
        None => return std::ptr::null_mut(),
    };

    let word_str = match str_util::char_buf_to_string(word) {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };

    let results = lib_obj.consult(&word_str);

    let result_json = format!(
        "[{}]",
        results
            .iter()
            .flat_map(|result| serde_json::to_string(result))
            .collect::<Vec<String>>()
            .join(","),
    );

    if let Ok(res) = CString::new(result_json) {
        res.into_raw()
    } else {
        std::ptr::null_mut()
    }
}

#[no_mangle]
pub extern "C" fn nstardict_drop_library(_: Option<Box<Library>>) {}
