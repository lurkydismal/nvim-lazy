-- TODO: Implement
if true then
    return {}
end

return {
    {
        "LazyVim/LazyVim",
        event = "VeryLazy",
        opts = {
            makeprg = "./build.sh",
            -- errorformat = "%f:%l:%c: %m",
        },
    },
}
