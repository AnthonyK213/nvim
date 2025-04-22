use anyhow::{Result, anyhow};
use reqwest;
use std::env;
use std::path::PathBuf;

const BACKUP_DIR: &str = "nvim_bak";
const ERR_NO_ERRORS: i32 = 0;
const ERR_INVALID_ARGS: i32 = 1;
const ERR_DOWNLOAD_FAILED: i32 = 2;
const ERR_EXTRACT_FAILED: i32 = 2;

#[derive(Debug)]
struct UpgradeArgs {
    pub install_dir: PathBuf,
    pub nvim_dir_name: String,
    pub backup_name: String,
    pub source_url: String,
    pub proxy: Option<String>,
}

impl UpgradeArgs {
    pub fn new(args: env::Args) -> Result<Self> {
        let mut install_dir: Option<PathBuf> = None;
        let mut nvim_dir_name: Option<String> = None;
        let mut backup_name: Option<String> = None;
        let mut source_url: Option<String> = None;
        let mut proxy: Option<String> = None;

        let mut args_iter = args.into_iter();
        while let Some(arg) = &args_iter.next() {
            match arg.as_str() {
                "--install_dir" => install_dir = args_iter.next().map(|v| v.into()),
                "--nvim_dir_name" => nvim_dir_name = args_iter.next(),
                "--backup_name" => backup_name = args_iter.next(),
                "--source_url" => source_url = args_iter.next(),
                "--proxy" => proxy = args_iter.next(),
                _ => {}
            }
        }

        if install_dir.is_none() || !install_dir.as_ref().unwrap().is_dir() {
            return Err(anyhow!("Err: install_dir"));
        }

        if nvim_dir_name.is_none() {
            return Err(anyhow!("Err: nvim_dir_name"));
        }

        if backup_name.is_none() {
            return Err(anyhow!("Err: backup_name"));
        }

        if source_url.is_none() {
            return Err(anyhow!("Err: source_url"));
        }

        Ok(Self {
            install_dir: install_dir.unwrap(),
            nvim_dir_name: nvim_dir_name.unwrap(),
            backup_name: backup_name.unwrap(),
            source_url: source_url.unwrap(),
            proxy,
        })
    }
}

#[derive(Debug)]
struct Upgrader {
    args: UpgradeArgs,
}

impl Upgrader {
    pub fn new(args: UpgradeArgs) -> Self {
        Self { args }
    }

    fn backup(&self) -> Result<()> {
        let install_dir = &self.args.install_dir;
        let nvim_dir_path = install_dir.clone().join(&self.args.nvim_dir_name);
        let backup_dir = install_dir.clone().join("nvim_bak");
        let backup_path = backup_dir.clone().join(&self.args.backup_name);

        if !nvim_dir_path.exists() || !nvim_dir_path.is_dir() {
            return Err(anyhow!("Invalid nvim_dir_path"));
        }

        if !backup_dir.exists() {
            std::fs::create_dir(backup_dir)?;
        }

        if backup_path.exists() {
            return Err(anyhow!("Backup exists"));
        }

        std::fs::rename(nvim_dir_path, backup_path)?;

        Ok(())
    }

    fn restore(&self) -> Result<()> {
        todo!()
    }

    async fn download(&self) -> Result<()> {
        let mut builder = reqwest::Client::builder();

        if let Some(p) = &self.args.proxy {
            let proxy = reqwest::Proxy::http(p)?;
            builder = builder.proxy(proxy);
        }

        let response = builder.build()?.get(&self.args.source_url).send().await?;

        Ok(())
    }

    fn extract(&self) -> Result<()> {
        todo!()
    }

    pub async fn run(&self) -> Result<()> {
        self.backup()?;
        self.download().await?;
        self.extract()?;

        Ok(())
    }
}

#[tokio::main]
async fn main() -> Result<()> {
    let args = UpgradeArgs::new(env::args())?;
    let upgrader = Upgrader::new(args);

    //TODO: Restore

    upgrader.run().await?;

    Ok(())
}
