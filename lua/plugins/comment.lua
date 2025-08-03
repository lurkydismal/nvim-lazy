return {
    "numToStr/Comment.nvim",
    opts = function(_, opts)
        local function toggle_if0()
            local esc =
                vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
            vim.api.nvim_feedkeys(esc, "x", false)

            local line1 = vim.fn.line("'<")
            local line2 = vim.fn.line("'>")

            -- search upward for #if 0
            local start = nil
            for i = line1 - 1, 1, -1 do
                local l = vim.trim(vim.fn.getline(i))
                if l == "#if 0" then
                    start = i
                    break
                elseif l == "#endif" then
                    break -- found nested endif first, bail
                end
            end

            -- search downward for #endif
            local finish = nil
            local last_line = vim.fn.line("$")
            for i = line2 + 1, last_line do
                local l = vim.trim(vim.fn.getline(i))
                if l == "#endif" then
                    finish = i
                    break
                elseif l == "#if 0" then
                    break -- found nested if first, bail
                end
            end

            if start and finish and start < line1 and finish > line2 then
                -- inside a block, remove it
                vim.api.nvim_buf_set_lines(0, finish - 1, finish, false, {})
                vim.api.nvim_buf_set_lines(0, start - 1, start, false, {})
            else
                -- wrap in #if 0 / #endif
                vim.api.nvim_buf_set_lines(0, line2, line2, false, { "#endif" })
                vim.api.nvim_buf_set_lines(
                    0,
                    line1 - 1,
                    line1 - 1,
                    false,
                    { "#if 0" }
                )
            end
        end

        -- Override keybinding only for C/C++
        vim.api.nvim_create_autocmd("FileType", {
            pattern = { "c", "cpp" },
            callback = function()
                vim.keymap.set(
                    "v",
                    "gc",
                    toggle_if0,
                    { buffer = true, desc = "Toggle #if 0/#endif" }
                )
            end,
        })
    end,
}
