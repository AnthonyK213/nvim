use nvim_oxi as oxi;

#[oxi::module]
fn hw() -> oxi::Result<()> {
    println!("Hello, world!");
    Ok(())
}
