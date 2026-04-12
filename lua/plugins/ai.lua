-- Custom AI integration using Gemini CLI
return {
    {
        "gemini-ai",
        name = "gemini-ai",
        dir = vim.fn.stdpath("config"),
        lazy = false, -- CRITICAL: Ensures the autocmd is registered when Neovim starts
        config = function()
            -- AI Commit Message Logic
            _G.generate_gemini_commit_message = function()
                -- Get current branch
                local branch_handle = io.popen("git branch --show-current")
                local branch = branch_handle:read("*a"):gsub("%s+", "")
                branch_handle:close()

                -- Get git status
                local status_handle = io.popen("git status --short")
                local status = status_handle:read("*a")
                status_handle:close()

                -- Get staged diff
                local diff_handle = io.popen("git diff --staged")
                local diff = diff_handle:read("*a")
                diff_handle:close()

                if diff == "" then
                    return
                end

                -- Create a temporary file for the diff
                local tmp_file = os.tmpname()
                local f = io.open(tmp_file, "w")
                f:write(diff)
                f:close()

                -- Get the current buffer to insert a placeholder
                local buf = vim.api.nvim_get_current_buf()
                local is_git_commit = vim.bo[buf].filetype == "gitcommit"
                
                -- Insert placeholder if we are in a commit buffer
                if is_git_commit then
                    vim.api.nvim_buf_set_lines(buf, 0, 1, false, { "Generating commit message..." })
                    vim.cmd("redraw") -- Force redraw so the user sees the placeholder immediately
                end

                vim.notify("Generating commit message...", vim.log.levels.INFO)

                -- The full prompt from copilot-chat.el
                local prompt_text = [[
You are a commit message generator.
Your ONLY task is to produce a Git commit message.
Your task is to generate a single Git commit message that **strictly follows the Conventional Commits v1.0.0 Specification**.

### INPUTS PROVIDED

- Current branch name: ]] .. branch .. [[
- git status summary:
]] .. status .. [[
- git diff --cached output of staged changes:
(provided via stdin)

### PRIMARY GOAL

Produce one short, complete commit message for the staged changes.

---

### SPEC FOR YOUR REFERENCE

Conventional Commits 1.0.0
==========================

Summary
=======

The Conventional Commits specification is a lightweight convention on top of commit messages.
It provides an easy set of rules for creating an explicit commit history; which makes it
easier to write automated tools on top of. This convention dovetails with SemVer,
by describing the features, fixes, and breaking changes made in commit messages.

Structure
=========

The commit message should be structured as follows:

<type>[optional scope]: <description>

[optional body]

[optional footer(s)]


Core Elements
============

The commit contains the following structural elements, to communicate intent to the consumers of your library:

1. fix: a commit of the type fix patches a bug in your codebase (this correlates with PATCH in Semantic Versioning).
2. feat: a commit of the type feat introduces a new feature to the codebase (this correlates with MINOR in Semantic Versioning).
3. BREAKING CHANGE: a commit that has a footer BREAKING CHANGE:, or appends a ! after the type/scope, introduces a breaking API change (correlating with MAJOR in Semantic Versioning). A BREAKING CHANGE can be part of commits of any type.
4. types other than fix: and feat: are allowed, for example @commitlint/config-conventional (based on the Angular convention) recommends build:, chore:, ci:, docs:, style:, refactor:, perf:, test:, and others.
5. footers other than BREAKING CHANGE: <description> may be provided and follow a convention similar to git trailer format.

Additional types are not mandated by the Conventional Commits specification, and have no implicit effect in Semantic Versioning (unless they include a BREAKING CHANGE). A scope may be provided to a commit's type, to provide additional contextual information and is contained within parenthesis, e.g., feat(parser): add ability to parse arrays.

Type Definitions
==============

Each commit type has a specific meaning and purpose:

- fix: A commit that patches a bug in your codebase
- feat: A commit that introduces a new feature to the codebase
- build: Changes that affect the build system or external dependencies
- chore: Changes to the build process or auxiliary tools and libraries
- ci: Changes to CI configuration files and scripts
- docs: Documentation only changes
- perf: A code change that improves performance
- refactor: A code change that neither fixes a bug nor adds a feature
- style: Changes that do not affect the meaning of the code
- test: Adding missing tests or correcting existing tests

Note: Types other than "fix:" and "feat:" are allowed and have no implicit effect in
semantic versioning (unless they include a BREAKING CHANGE).

Detailed Rules
=============

1. Commits MUST be prefixed with a type, which consists of a noun, feat, fix, etc., followed by the OPTIONAL scope, OPTIONAL !, and REQUIRED terminal colon and space.
2. The type feat MUST be used when a commit adds a new feature to your application or library.
3. The type fix MUST be used when a commit represents a bug fix for your application.
4. A scope MAY be provided after a type. A scope MUST consist of a noun describing a section of the codebase surrounded by parenthesis, e.g., fix(parser):
5. A description MUST immediately follow the colon and space after the type/scope prefix. The description is a short summary of the code changes, e.g., fix: array parsing issue when multiple spaces were contained in string.
6. A longer commit body MAY be provided after the short description, providing additional contextual information about the code changes. The body MUST begin one blank line after the description.
7. A commit body is free-form and MAY consist of any number of newline separated paragraphs.
8. One or more footers MAY be provided one blank line after the body. Each footer MUST consist of a word token, followed by either a :<space> or <space># separator, followed by a string value (this is inspired by the git trailer convention).
9. A footer's token MUST use - in place of whitespace characters, e.g., Acked-by (this helps differentiate the footer section from a multi-paragraph body). An exception is made for BREAKING CHANGE, which MAY also be used as a token.
10. A footer's value MAY contain spaces and newlines, and parsing MUST terminate when the next valid footer token/separator pair is observed.
11. Breaking changes MUST be indicated in the type/scope prefix of a commit, or as an entry in the footer.
12. If included as a footer, a breaking change MUST consist of the uppercase text BREAKING CHANGE, followed by a colon, space, and description, e.g., BREAKING CHANGE: environment variables now take precedence over config files.
13. If included in the type/scope prefix, breaking changes MUST be indicated by a ! immediately before the :. If ! is used, BREAKING CHANGE: MAY be omitted from the footer section, and the commit description SHALL be used to describe the breaking change.
14. Types other than feat and fix MAY be used in your commit messages, e.g., docs: update ref docs.
15. The units of information that make up Conventional Commits MUST NOT be treated as case sensitive by implementors, with the exception of BREAKING CHANGE which MUST be uppercase.
16. BREAKING-CHANGE MUST be synonymous with BREAKING CHANGE, when used as a token in a footer.

### OUTPUT FORMAT
- Return **only** the commit message text—no code fences, no commentary, no extra markup or explanations.
- The summary (first) line **must** be imperative, present tense, ≤72 characters, and **must not** end with a period.
- Ensure there is **EXACTLY ONE blank line** between the subject (first line) and the body.
- Wrap all body lines at a maximum of 72 characters.
- If a body is included, format it as a clean, concise bullet list, each line starting with - .
- Ensure there is **EXACTLY ONE blank line** after the body (before any footers or the end of the message).
]]

                -- Run cliproxyapi using curl for better performance
                local api_url = "http://localhost:8317/v1/chat/completions"
                local model = "gemini-2.5-flash-lite"
                
                -- Construct the JSON payload for OpenAI-compatible API
                local payload = {
                    model = model,
                    messages = {
                        {
                            role = "user",
                            content = prompt_text .. "\n\nGit diff:\n" .. diff
                        }
                    },
                    temperature = 0.2
                }
                
                local json_payload = vim.fn.json_encode(payload)
                local cmd = string.format(
                    "curl -s -X POST -H 'Content-Type: application/json' -H 'Authorization: Bearer any-value' -d %s %s",
                    vim.fn.shellescape(json_payload),
                    vim.fn.shellescape(api_url)
                )
                
                local stdout_lines = {}
                vim.fn.jobstart(cmd, {
                    stdout_buffered = true,
                    on_stdout = function(_, data)
                        if data then
                            vim.list_extend(stdout_lines, data)
                        end
                    end,
                    on_exit = function(_, exit_code)
                        os.remove(tmp_file)
                        vim.schedule(function()
                            if exit_code == 0 and #stdout_lines > 0 then
                                local response_text = table.concat(stdout_lines, "")
                                local ok, decoded = pcall(vim.fn.json_decode, response_text)
                                
                                if ok and decoded and decoded.choices and decoded.choices[1] and decoded.choices[1].message then
                                    local content = decoded.choices[1].message.content
                                    -- Split content into lines and remove potential markdown code blocks
                                    content = content:gsub("^```%a*\n", ""):gsub("\n```$", "")
                                    local result_lines = vim.split(content, "\n")
                                    
                                    if is_git_commit and vim.api.nvim_buf_is_valid(buf) then
                                        vim.api.nvim_buf_set_lines(buf, 0, -1, false, result_lines)
                                    else
                                        vim.api.nvim_put(result_lines, "l", true, true)
                                    end
                                    vim.notify("Commit message generated!", vim.log.levels.INFO)
                                else
                                    if is_git_commit and vim.api.nvim_buf_is_valid(buf) then
                                        vim.api.nvim_buf_set_lines(buf, 0, 1, false, { "" })
                                    end
                                    vim.notify("Failed to parse API response.", vim.log.levels.ERROR)
                                    if not ok then print("JSON Error: " .. decoded) end
                                end
                            else
                                if is_git_commit and vim.api.nvim_buf_is_valid(buf) then
                                    vim.api.nvim_buf_set_lines(buf, 0, 1, false, { "" })
                                end
                                vim.notify("Failed to generate commit message via API.", vim.log.levels.ERROR)
                            end
                        end)
                    end
                })
            end

            -- Autocmd to generate commit message when opening a commit buffer
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "gitcommit",
                callback = function()
                    vim.defer_fn(function()
                        local buf = vim.api.nvim_get_current_buf()
                        if not vim.api.nvim_buf_is_valid(buf) then return end
                        
                        -- Check if the first line is empty (standard for a fresh commit)
                        local lines = vim.api.nvim_buf_get_lines(buf, 0, 1, false)
                        if #lines > 0 and lines[1] == "" then
                            _G.generate_gemini_commit_message()
                        end
                    end, 100)
                end,
            })
        end,
        keys = {
            {
                "<leader>ag",
                function()
                    vim.cmd("botright vsplit")
                    local width = math.floor(vim.o.columns / 3)
                    vim.cmd("vertical resize " .. width)
                    vim.cmd("terminal gemini -y")
                end,
                desc = "Open Gemini CLI",
            },
            {
                "<leader>gm",
                function()
                    _G.generate_gemini_commit_message()
                end,
                desc = "Generate Commit Message (Gemini)",
            },
        },
    },
}
