-- Custom AI integration using Gemini CLI
return {
    {
        "gemini-cli-launcher",
        dir = vim.fn.stdpath("config"),
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
        },
    },
}
