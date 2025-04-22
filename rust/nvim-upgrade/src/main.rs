use anyhow::{Result, anyhow};
use reqwest::{Client, Proxy, Url};
use std::env;
use std::io::Write;
use std::path::PathBuf;
use std::str::FromStr;
use std::time::Duration;

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
    pub source_url: Url,
    pub proxy: Option<Proxy>,
}

impl UpgradeArgs {
    pub fn new(args: env::Args) -> Result<Self> {
        let mut install_dir = None;
        let mut nvim_dir_name = None;
        let mut backup_name = None;
        let mut source_url = None;
        let mut proxy = None;

        let mut args_iter = args.into_iter();
        while let Some(arg) = &args_iter.next() {
            match arg.as_str() {
                "--install-dir" => install_dir = args_iter.next().map(|v| PathBuf::from(&v)),
                "--nvim-dir-name" => nvim_dir_name = args_iter.next(),
                "--backup-name" => backup_name = args_iter.next(),
                "--source-url" => {
                    source_url = args_iter.next().and_then(|v| Url::from_str(&v).ok())
                }
                "--proxy" => proxy = args_iter.next().and_then(|v| Proxy::http(v).ok()),
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
    nvim_dir_path: PathBuf,
    backup_dir: PathBuf,
    backup_path: PathBuf,
    download_path: PathBuf,
    download_name: String,
}

impl Upgrader {
    pub fn new(args: UpgradeArgs) -> Result<Self> {
        let install_dir = &args.install_dir;
        let nvim_dir_path = install_dir.join(&args.nvim_dir_name);
        let backup_dir = install_dir.join("nvim_bak");
        let backup_path = backup_dir.join(&args.backup_name);
        let download_name = args
            .source_url
            .path_segments()
            .and_then(|segs| segs.last())
            .and_then(|name| if name.is_empty() { None } else { Some(name) })
            .ok_or(anyhow!("Invalid download_name"))?
            .to_string();
        let download_path = backup_dir.join(&download_name);

        Ok(Self {
            args,
            nvim_dir_path,
            backup_dir,
            backup_path,
            download_path,
            download_name,
        })
    }

    fn backup(&self) -> Result<()> {
        if !self.nvim_dir_path.exists() || !self.nvim_dir_path.is_dir() {
            return Err(anyhow!("Invalid nvim_dir_path"));
        }

        if !self.backup_dir.exists() {
            std::fs::create_dir(&self.backup_dir)?;
        }

        if self.backup_path.exists() {
            return Err(anyhow!("Backup exists"));
        }

        std::fs::rename(&self.nvim_dir_path, &self.backup_path)?;

        Ok(())
    }

    fn restore(&self) -> Result<()> {
        todo!()
    }

    async fn download(&self) -> Result<()> {
        let mut builder = Client::builder();

        if let Some(p) = &self.args.proxy {
            builder = builder.proxy(p.clone());
        }

        let resp = builder
            .build()?
            .get(self.args.source_url.as_ref())
            .send()
            .await?;

        let mut dest = std::fs::File::create(&self.download_path)?;
        let content = resp.bytes().await?;
        dest.write_all(&content)?;

        Ok(())
    }

    fn extract(&self) -> Result<()> {
        Ok(())
    }

    pub async fn run(&self) -> Result<()> {
        // self.backup()?;
        // self.download().await?;
        // self.extract()?;
        println!("{:?}", self);
        tokio::time::sleep(Duration::from_secs(10)).await;

        Ok(())
    }
}

#[tokio::main]
async fn main() -> Result<()> {
    let args = UpgradeArgs::new(env::args())?;
    let upgrader = Upgrader::new(args)?;

    // TODO: Restore

    upgrader.run().await?;

    Ok(())
}
