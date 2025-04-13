use lettre::transport::smtp::authentication::Credentials;
use lettre::{Message, SmtpTransport, Transport};
use std::collections::HashMap;
use std::ffi::{c_char, CString};
use ex_util::{str_try_parse, str_buf_to_string};

macro_rules! mailbox_parse {
    ($string: expr, $code: expr) => {
        match $string.parse::<lettre::message::Mailbox>() {
            Ok(v) => v,
            Err(_) => return $code,
        }
    };
}

fn fetch_inbox_top(
    server: &str,
    port: u16,
    user_name: &str,
    password: &str,
) -> imap::error::Result<Option<String>> {
    let client = imap::ClientBuilder::new(&server, port).native_tls()?;

    let mut imap_session = client
        .login_with_id(
            user_name,
            password,
            &HashMap::from_iter([("name", "Nmail"), ("version", "0.1.0")]),
        )
        .map_err(|e| e.0)?;

    imap_session.select("INBOX")?;
    let new_seqs = imap_session.search("NEW")?;

    let mut bodys = Vec::<String>::new();

    for seq in &new_seqs {
        if let Ok(messages) = imap_session.fetch(seq.to_string(), "RFC822") {
            let message = if let Some(m) = messages.iter().next() {
                m
            } else {
                continue;
            };

            if let Some(body) = message.body() {
                if let Ok(body) = std::str::from_utf8(body) {
                    bodys.push(body.to_string());
                }
            }
        }
    }

    imap_session.logout()?;

    if bodys.len() == 0 {
        Ok(None)
    } else {
        Ok(Some(bodys.join("\r\n\r\n")))
    }
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
    let _from = mailbox_parse!(str_try_parse!(from, 1), 9);
    let _to = mailbox_parse!(str_try_parse!(to, 2), 10);
    let _reply_to = mailbox_parse!(str_try_parse!(reply_to, 3), 11);
    let _subject = str_try_parse!(subject, 4);
    let _body = str_try_parse!(body, 5);
    let _user_name = str_try_parse!(user_name, 6);
    let _password = str_try_parse!(password, 7);
    let _server = str_try_parse!(server, 8);

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

#[no_mangle]
pub extern "C" fn nmail_fetch(
    server: *const c_char,
    port: i32,
    user_name: *const c_char,
    password: *const c_char,
) -> *mut c_char {
    let _server = str_try_parse!(server, std::ptr::null_mut());
    let _port: u16 = match port.try_into() {
        Ok(p) => p,
        Err(_) => return std::ptr::null_mut(),
    };
    let _user_name = str_try_parse!(user_name, std::ptr::null_mut());
    let _password = str_try_parse!(password, std::ptr::null_mut());

    if let Ok(Some(_body)) = fetch_inbox_top(&_server, _port, &_user_name, &_password) {
        if let Ok(body) = CString::new(_body) {
            return body.into_raw();
        }
    }
    std::ptr::null_mut()
}
