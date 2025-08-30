local function trim(s)
    return s:match("^%s*(.-)%s*$")
end

return {
    "numToStr/Comment.nvim",
    opts = function(_, _)
        local function add_comment()
            local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
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
                vim.api.nvim_buf_set_lines(0, line1 - 1, line1 - 1, false, { "#if 0" })
            end
        end

        -- FIX: Remove comment instead of { } scope
        local function remove_comment()
            -- figure out range to query (visual selection or cursor)
            local mode = vim.fn.mode()
            local srow, scol, erow, ecol
            if mode:match("[vV]") then
                -- visual; convert to 0-indexed
                srow = vim.fn.line("'<") - 1
                erow = vim.fn.line("'>") - 1
                scol = vim.fn.col("'<") - 1
                ecol = vim.fn.col("'>") - 1
                vim.cmd("normal! <Esc>")
            else
                local r, c = unpack(vim.api.nvim_win_get_cursor(0))
                srow, scol, erow, ecol = r - 1, c, r - 1, c
            end

            local parser = vim.treesitter.get_parser(0)
            if not parser then
                vim.notify("treesitter: no parser for buffer", vim.log.levels.WARN)
                return
            end

            local tree = parser:parse()[1]
            if not tree then
                return
            end
            local root = tree:root()

            -- find the smallest named node that covers the range
            local node = root:named_descendant_for_range(srow, scol, erow, ecol)
            if not node then
                return
            end

            -- climb until we find a block-like node
            local function is_block_type(t)
                -- common names: C-family: "compound_statement"
                -- JS: "statement_block" / "block" / "program" etc.
                -- this list is permissive — add types your grammars use
                return t == "compound_statement"
                    or t == "block"
                    or t == "statement_block"
                    or t == "scoped_block"
                    or t == "block_statement"
                    or t == "object" -- object for some JS cases
            end

            while node and not is_block_type(node:type()) do
                node = node:parent()
            end
            if not node then
                vim.notify("No enclosing block found", vim.log.levels.INFO)
                return
            end

            -- get node range (0-indexed, end exclusive column)
            local ns, cs, ne, ce = node:range()
            local start_line = vim.api.nvim_buf_get_lines(0, ns, ns + 1, false)[1] or ""
            local end_line = vim.api.nvim_buf_get_lines(0, ne, ne + 1, false)[1] or ""
            local s_trim = trim(start_line)
            local e_trim = trim(end_line)

            -- Helper: remove first occurrence of '{' on a given line
            local function remove_first_brace_on_line(line_num, brace_char)
                local l = vim.api.nvim_buf_get_lines(0, line_num, line_num + 1, false)[1]
                if not l then
                    return
                end
                local found = l:find(brace_char, 1, true)
                if not found then
                    return
                end
                local new = l:sub(1, found - 1) .. l:sub(found + 1)
                vim.api.nvim_buf_set_lines(0, line_num, line_num + 1, false, { new })
            end

            -- If both braces are on their own lines -> delete those lines.
            if s_trim == "{" and e_trim == "}" then
                -- delete end first to keep start index valid
                vim.api.nvim_buf_set_lines(0, ne, ne + 1, false, {})
                vim.api.nvim_buf_set_lines(0, ns, ns + 1, false, {})
                -- After deleting both lines, the inner block now sits at ns .. (ne-2)
                -- Reindent new inner block if any lines
                local inner_first = ns
                local inner_last = ne - 2
                if inner_last >= inner_first then
                    vim.cmd(string.format("%d,%dnormal! ==", inner_first + 1, inner_last + 1))
                end
            else
                -- Otherwise try to remove brace characters in place (handles inline braces)
                -- remove opening brace if present on the start line
                if start_line:find("{", 1, true) then
                    remove_first_brace_on_line(ns, "{")
                end
                -- remove closing brace: remove last '}' on end line
                local el = vim.api.nvim_buf_get_lines(0, ne, ne + 1, false)[1] or ""
                local lastpos = nil
                for i = #el, 1, -1 do
                    if el:sub(i, i) == "}" then
                        lastpos = i
                        break
                    end
                end
                if lastpos then
                    local new = el:sub(1, lastpos - 1) .. el:sub(lastpos + 1)
                    vim.api.nvim_buf_set_lines(0, ne, ne + 1, false, { new })
                end
                -- Reindent the (rough) inner range: after edits, inner lines sit at ns .. (ne - 1)
                local new_inner_first = ns
                local new_inner_last = math.max(ns, ne - 1)
                vim.cmd(string.format("%d,%dnormal! ==", new_inner_first + 1, new_inner_last + 1))
            end

            -- keep cursor roughly where it was (clamp to line length)
            local cur_r, cur_c = unpack(vim.api.nvim_win_get_cursor(0))
            cur_r = math.max(1, math.min(vim.fn.line("$"), cur_r))
            local line_len = #(vim.api.nvim_buf_get_lines(0, cur_r - 1, cur_r, false)[1] or "")
            cur_c = math.max(0, math.min(line_len, cur_c))
            vim.api.nvim_win_set_cursor(0, { cur_r, cur_c })
        end

        -- Override keybinding only for C/C++
        vim.api.nvim_create_autocmd("FileType", {
            pattern = { "c", "cpp" },
            callback = function()
                vim.keymap.set("v", "gs", add_comment, { buffer = true, desc = "Add #if 0 #endif scone" })
                vim.keymap.set("n", "gs", remove_comment, { buffer = true, desc = "Remove #if 0 #endif scone" })
            end,
        })
    end,
}
