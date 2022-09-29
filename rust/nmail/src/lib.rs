use lettre::transport::smtp::authentication::Credentials;
use lettre::{Message, SmtpTransport, Transport};
use libc::c_char;
use std::ffi::CStr;

macro_rules! string_marshal {
    ($c_buf: expr, $code: expr) => {
        match c_buf_to_string($c_buf) {
            Ok(v) => v,
            Err(_) => return $code,
        }
    };
}

macro_rules! mailbox_parse {
    ($string: expr, $code: expr) => {
        match $string.parse::<lettre::message::Mailbox>() {
            Ok(v) => v,
            Err(_) => return $code,
        }
    };
}

fn c_buf_to_string(c_buf: *const c_char) -> Result<String, std::str::Utf8Error> {
    Ok(unsafe { CStr::from_ptr(c_buf) }.to_str()?.to_owned())
}

#[no_mangle]
pub extern "C" fn nmail_send(
    from: *const c_char,
    to: *const c_char,
    reply_to: *const c_char,
    subject: *const c_char,
    body: *const c_char,
    user_name: *const c_char,
    password: *const c_char,
    server: *const c_char,
) -> i32 {
    let _from = mailbox_parse!(string_marshal!(from, 1), 9);
    let _reply_to = mailbox_parse!(string_marshal!(reply_to, 2), 10);
    let _to = mailbox_parse!(string_marshal!(to, 3), 11);
    let _subject = string_marshal!(subject, 4);
    let _body = string_marshal!(body, 5);
    let _user_name = string_marshal!(user_name, 6);
    let _password = string_marshal!(password, 7);
    let _server = string_marshal!(server, 8);

    let email = match Message::builder()
        .from(_from)
        .to(_to)
        .reply_to(_reply_to)
        .subject(_subject)
        .body(_body)
    {
        Ok(v) => v,
        Err(_) => return 12,
    };

    let creds = Credentials::new(_user_name, _password);

    let mailer = match SmtpTransport::relay(&_server) {
        Ok(v) => v,
        Err(_) => return 13,
    }
    .credentials(creds)
    .build();

    match mailer.send(&email) {
        Ok(_) => 0,
        Err(_) => 14,
    }
}
