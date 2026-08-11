-- compile / recompile, replacing Emacs' `compile` and `recompile`.
--
-- The Emacs workflow this reproduces: SPC c c prompts for a shell command
-- (pre-filled with the last one), runs it asynchronously, streams output into a
-- buffer you can watch, and on exit parses that output into the quickfix list so
-- ]q / [q step through the errors. SPC c C re-runs without prompting.
--
-- No plugin: this is ~80 lines of vim.system plus setqflist. A task runner like
-- overseer.nvim adds templates and a task list on top; see follow-up F9.

local M = {}

local state = {
    cmd = nil, -- last command, for recompile
    buf = nil, -- output buffer
    job = nil, -- running handle
}

-- Error formats, most specific first. Verilator comes first because it is the
-- main compiler here and its `%Error:` prefix would otherwise be swallowed by
-- the generic patterns. `%%` is a literal percent in an errorformat.
local errorformat = table.concat({
    -- Verilator. `%%` is a literal `%`; the following `%t` then captures the
    -- E or W of Error/Warning so quickfix knows the severity.
    [[%%%trror: %f:%l:%c: %m]],
    [[%%%trror-%*[A-Z0-9_]: %f:%l:%c: %m]],
    [[%%%tarning-%*[A-Z0-9_]: %f:%l:%c: %m]],
    [[%f:%l:%c: %trror: %m]],
    [[%f:%l:%c: %tarning: %m]],
    [[%f:%l:%c: %m]],
    [[%f:%l: %trror: %m]],
    [[%f:%l: %m]],
    -- Python tracebacks
    [[  File "%f"\, line %l\, in %m]],
    [[  File "%f"\, line %l]],
}, ",")

local function output_buf()
    if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
        return state.buf
    end
    state.buf = vim.api.nvim_create_buf(false, true)
    vim.bo[state.buf].buftype = "nofile"
    vim.bo[state.buf].bufhidden = "hide"
    vim.api.nvim_buf_set_name(state.buf, "[compilation]")
    return state.buf
end

-- Show the output buffer in a split, without stealing focus.
local function show(buf)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == buf then
            return
        end
    end
    local current = vim.api.nvim_get_current_win()
    vim.cmd("botright 15split")
    vim.api.nvim_win_set_buf(0, buf)
    vim.wo.number = false
    vim.api.nvim_set_current_win(current)
end

local function append(buf, chunk)
    if not chunk or not vim.api.nvim_buf_is_valid(buf) then
        return
    end
    local lines = vim.split(chunk:gsub("\r\n", "\n"), "\n", { trimempty = false })
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
    vim.bo[buf].modifiable = false
    -- Follow the output, like compilation-scroll-output in Emacs.
    for _, win in ipairs(vim.fn.win_findbuf(buf)) do
        vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })
    end
end

function M.run(cmd)
    if not cmd or cmd == "" then
        return
    end
    if state.job then
        state.job:kill(15)
    end
    state.cmd = cmd

    local buf = output_buf()
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "$ " .. cmd, "" })
    vim.bo[buf].modifiable = false
    show(buf)

    local on_data = function(_, data)
        vim.schedule(function()
            append(buf, data)
        end)
    end

    state.job = vim.system({ "sh", "-c", cmd }, {
        cwd = vim.fn.getcwd(),
        text = true,
        stdout = on_data,
        stderr = on_data,
    }, function(res)
        vim.schedule(function()
            state.job = nil
            append(buf, "\n[exit " .. res.code .. "]")

            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            vim.fn.setqflist({}, " ", { title = cmd, lines = lines, efm = errorformat })

            -- Keep only lines that actually matched a file:line. Without this
            -- every echoed command and blank line becomes a quickfix entry you
            -- have to step past.
            local items = vim.tbl_filter(function(item)
                return item.valid == 1
            end, vim.fn.getqflist())
            vim.fn.setqflist({}, "r", { title = cmd, items = items })

            if res.code == 0 then
                vim.notify("Compilation finished: " .. cmd, vim.log.levels.INFO)
            else
                vim.notify(
                    ("Compilation exited %d (%d quickfix entries)"):format(res.code, #items),
                    vim.log.levels.ERROR
                )
                if #items > 0 then
                    vim.cmd("copen")
                end
            end
        end)
    end)
end

-- SPC c c -- prompt, pre-filled with the previous command.
function M.compile()
    vim.ui.input({ prompt = "Compile: ", default = state.cmd or "", completion = "shellcmd" }, function(cmd)
        M.run(cmd)
    end)
end

-- SPC c C -- re-run the last command without prompting.
function M.recompile()
    if not state.cmd then
        return M.compile()
    end
    M.run(state.cmd)
end

function M.stop()
    if state.job then
        state.job:kill(15)
        state.job = nil
        vim.notify("Compilation stopped", vim.log.levels.WARN)
    end
end

return M
