use std::ffi::{c_char, CStr, CString};

pub fn char_buf_to_string(c_buf: *const c_char) -> Result<String, std::str::Utf8Error> {
    Ok(unsafe { CStr::from_ptr(c_buf) }.to_str()?.to_owned())
}

#[unsafe(no_mangle)]
pub extern "C" fn ffi_util_str_util_str_free(s: *mut c_char) {
    if s.is_null() {
        return;
    }

    unsafe {
        drop(CString::from_raw(s));
    }
}
