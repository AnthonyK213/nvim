use anyhow::{Result, anyhow};
use flate2::read::GzDecoder;
use std::path::PathBuf;

#[derive(Debug)]
struct UpgradeArgs {
    pub install_dir: PathBuf,
    pub nvim_dir_name: String,
    pub backup_dir: PathBuf,
    pub backup_name: String,
    pub source_name: String,
}

impl UpgradeArgs {
    pub fn new(args: std::env::Args) -> Result<Self> {
        let mut install_dir: Option<PathBuf> = None;
        let mut nvim_dir_name = None;
        let mut backup_dir: Option<PathBuf> = None;
        let mut backup_name = None;
        let mut source_name = None;

        let mut args_iter = args.into_iter();
        while let Some(arg) = &args_iter.next() {
            match arg.as_str() {
                "--install-dir" => install_dir = args_iter.next().map(|v| v.into()),
                "--nvim-dir-name" => nvim_dir_name = args_iter.next(),
                "--backup-dir" => backup_dir = args_iter.next().map(|v| v.into()),
                "--backup-name" => backup_name = args_iter.next(),
                "--source-name" => source_name = args_iter.next(),
                _ => {}
            }
        }

        Ok(Self {
            install_dir: install_dir.ok_or(anyhow!("No install_dir"))?,
            nvim_dir_name: nvim_dir_name.ok_or(anyhow!("No nvim_dir_name"))?,
            backup_dir: backup_dir.ok_or(anyhow!("No backup_dir"))?,
            backup_name: backup_name.ok_or(anyhow!("No backup_name"))?,
            source_name: source_name.ok_or(anyhow!("No source_name"))?,
        })
    }
}

#[derive(Debug)]
struct Upgrader {
    args: UpgradeArgs,
    nvim_dir_path: PathBuf,
    backup_path: PathBuf,
    source_path: PathBuf,
}

impl Upgrader {
    pub fn new(args: UpgradeArgs) -> Self {
        let install_dir = &args.install_dir;
        let nvim_dir_path = install_dir.join(&args.nvim_dir_name);
        let backup_dir = &args.backup_dir;
        let backup_path = backup_dir.join(&args.backup_name);
        let source_path = backup_dir.join(&args.source_name);

        Self {
            args,
            nvim_dir_path,
            backup_path,
            source_path,
        }
    }

    fn backup(&self) -> Result<()> {
        if !self.nvim_dir_path.is_dir() {
            return Err(anyhow!("Invalid nvim_dir_path"));
        }

        if !self.args.backup_dir.is_dir() {
            return Err(anyhow!("Invalid backup_dir"));
        }

        if self.backup_path.exists() {
            return Err(anyhow!("Backup exists"));
        }

        std::fs::rename(&self.nvim_dir_path, &self.backup_path)?;

        Ok(())
    }

    fn extract(&self) -> Result<()> {
        if !self.source_path.is_file() {
            return Err(anyhow!("Invalid source_path"));
        }

        let file = std::fs::File::open(&self.source_path)?;

        let res = if let Some(ext) = self.source_path.extension() {
            match ext.to_str() {
                Some("zip") => {
                    zip_extract::extract(file, &self.nvim_dir_path, true)?;
                    Ok(())
                }
                Some("gz") => {
                    let t = GzDecoder::new(file);
                    let mut archive = tar::Archive::new(t);
                    archive.unpack(&self.nvim_dir_path)?;
                    Ok(())
                }
                _ => Err(anyhow!("Unknown archive")),
            }
        } else {
            Err(anyhow!("Invalid archive"))
        };

        std::fs::remove_file(&self.source_path)?;

        res?;

        Ok(())
    }

    fn restore(&self) -> Result<()> {
        todo!()
    }

    pub fn run(&self) -> Result<()> {
        self.backup()?;
        self.extract()?;

        // TODO: Restore on errors.

        Ok(())
    }
}

fn main() -> Result<()> {
    let args = UpgradeArgs::new(std::env::args())?;
    let upgrader = Upgrader::new(args);
    upgrader.run()?;

    Ok(())
}
