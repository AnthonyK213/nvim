use nvim_oxi as oxi;

#[oxi::module]
fn hw() -> oxi::Result<i32> {
    Ok(42)
}
