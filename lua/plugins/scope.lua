return {
    "numToStr/Comment.nvim",
    opts = function(_, opts)
        local function toggle_scope()
            local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
            vim.api.nvim_feedkeys(esc, "x", false)

            local line1 = vim.fn.line("'<")
            local line2 = vim.fn.line("'>")

            -- search upward for {
            local start = nil
            for i = line1 - 1, 1, -1 do
                local l = vim.trim(vim.fn.getline(i))
                if l == "{" then
                    start = i
                    break
                elseif l == "}" then
                    break -- found nested } first, bail
                end
            end

            -- search downward for }
            local finish = nil
            local last_line = vim.fn.line("$")
            for i = line2 + 1, last_line do
                local l = vim.trim(vim.fn.getline(i))
                if l == "}" then
                    finish = i
                    break
                elseif l == "{" then
                    break -- found nested if first, bail
                end
            end

            local current_row, current_col = unpack(vim.api.nvim_win_get_cursor(0))

            local function get_indent_of(line)
                local s = vim.fn.getline(line)
                -- Count leading spaces (or tabs — adjust if you indent with tabs)
                local _, e = s:find("%S")
                -- If no non-space found, e = nil → treat as full-line indent
                return e and (e - 1) or #s
            end

            local old_indent = get_indent_of(current_row)

            if start and finish and start < line1 and finish > line2 then
                -- Inside a block, remove it
                vim.api.nvim_buf_set_lines(0, finish - 1, finish, false, {})
                vim.api.nvim_buf_set_lines(0, start - 1, start, false, {})

                vim.cmd(string.format("%d,%dnormal! ==", start, finish))

                local new_indent = get_indent_of(current_row - 1)

                local delta = new_indent - old_indent

                vim.api.nvim_win_set_cursor(0, { current_row - 1, current_col + delta })
            else
                -- Wrap in { / }
                vim.api.nvim_buf_set_lines(0, line2, line2, false, { "}" })
                vim.api.nvim_buf_set_lines(0, line1 - 1, line1 - 1, false, { "{" })

                vim.cmd(string.format("%d,%dnormal! ==", line1 - 1, line2 + 2))

                local new_indent = get_indent_of(current_row + 1)

                local delta = new_indent - old_indent

                vim.api.nvim_win_set_cursor(0, { current_row + 1, current_col + delta })
            end
        end

        -- Override keybinding only for C/C++
        vim.api.nvim_create_autocmd("FileType", {
            pattern = { "c", "cpp" },
            callback = function()
                vim.keymap.set("v", "gs", toggle_scope, { buffer = true, desc = "Toggle {} scope" })
            end,
        })
    end,
}
