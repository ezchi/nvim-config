return {
    {
        "ezchi/cliproxyapi.nvim",
        lazy = false, -- Load on startup to ensure server is ready
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("cliproxyapi").setup({
                -- Use default port 8317
            })
        end,
    },
    {
        "ezchi/git-commit-gen.nvim",
        lazy = false, -- Load on startup to register autocmd properly
        dependencies = { "ezchi/cliproxyapi.nvim" },
        config = function()
            require("git-commit-gen").setup({
                model = "gemini-2.5-flash-lite",
                auto_generate = true,
            })
        end,
        keys = {
            {
                "<leader>gm",
                function()
                    require("git-commit-gen.generator").generate()
                end,
                desc = "Generate Commit Message (AI)",
            },
            {
                "<leader>gM",
                function()
                    local cliproxyapi = require("cliproxyapi")
                    cliproxyapi.get_models(function(models, err)
                        if err then
                            vim.notify("Failed to fetch models: " .. err, vim.log.levels.ERROR)
                            return
                        end
                        
                        local model_ids = {}
                        if models and models.data then
                            for _, m in ipairs(models.data) do
                                table.insert(model_ids, m.id)
                            end
                        end
                        table.sort(model_ids)
                        table.insert(model_ids, 1, "custom...")
                        
                        vim.ui.select(model_ids, {
                            prompt = "Select Model for Git Commit Generation:",
                        }, function(choice)
                            if not choice then return end
                            
                            if choice == "custom..." then
                                vim.ui.input({ prompt = "Enter model ID: " }, function(input)
                                    if input and input ~= "" then
                                        require("git-commit-gen").config.model = input
                                        vim.notify("Model set to: " .. input)
                                    end
                                end)
                            else
                                require("git-commit-gen").config.model = choice
                                vim.notify("Model set to: " .. choice)
                            end
                        end)
                    end)
                end,
                desc = "Change Commit Generation Model",
            },
        },
    },
}
