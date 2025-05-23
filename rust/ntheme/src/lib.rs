use std::ffi::c_int;

const NTHEME_DARK: c_int = 0;
const NTHEME_LIGHT: c_int = 1;
const NTHEME_UNSPECIFIED: c_int = 2;
const NTHEME_ERROR: c_int = -1;

#[unsafe(no_mangle)]
pub extern "C" fn ntheme_detect() -> c_int {
    if let Ok(mode) = dark_light::detect() {
        match mode {
            dark_light::Mode::Dark => NTHEME_DARK,
            dark_light::Mode::Light => NTHEME_LIGHT,
            dark_light::Mode::Unspecified => NTHEME_UNSPECIFIED,
        }
    } else {
        NTHEME_ERROR
    }
}
