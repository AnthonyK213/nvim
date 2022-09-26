use lettre::transport::smtp::authentication::Credentials;
use lettre::{Message, SmtpTransport, Transport};
use nvim_oxi::{self as oxi, api, Dictionary, Function, Object};

#[oxi::module]
fn nmail() -> oxi::Result<Dictionary> {
    let send = Function::from_fn(
        |(from, reply_to, to, subject, body, user_name, password, server): (
            String,
            String,
            String,
            String,
            String,
            String,
            String,
            String,
        )| {
            let email = Message::builder()
                .from(from.parse().unwrap())
                .reply_to(reply_to.parse().unwrap())
                .to(to.parse().unwrap())
                .subject(subject)
                .body(body)
                .unwrap();

            let creds = Credentials::new(user_name, password);

            let mailer = SmtpTransport::relay(&server)
                .unwrap()
                .credentials(creds)
                .build();

            match mailer.send(&email) {
                Ok(_) => oxi::print!("Email sent successfully!"),
                Err(_) => oxi::print!("Could not send email."),
            };

            Ok(())
        },
    );

    let sync = 42;

    Ok(Dictionary::from_iter([
        ("send", Object::from(send)),
        ("sync", Object::from(sync)),
    ]))
}
