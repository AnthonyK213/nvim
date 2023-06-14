local old_version = false

if not vim.uv then
    vim.uv = vim.loop
    old_version = true
end

if old_version then
    vim.notify_once("The current version may have some deprecated features, time to upgrade!",
        vim.log.levels.WARN)
end
