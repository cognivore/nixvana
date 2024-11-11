{ pkgs, ...}:
{
  programs.neovim = {
    enable = true;
    # Alias!
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      lazy-lsp-nvim
      lsp-zero-nvim
      copilot-vim
      vimshell
      rainbow-delimiters-nvim
      fzf-vim
      feline-nvim
      # TODO: configure https://github.com/jordanaq/.dotfiles/blob/d1f94b2a74aa0a62a3ac314f54c624ea8be2e233/user/utils/neovim/assets/nvim/plugin/treesitter.lua
      nvim-treesitter
      lsp-format-nvim
      nvim-cmp
      nvim-lspconfig
      cmp-nvim-lsp
      luasnip
    ];
    extraConfig = ''
    set number relativenumber
    let mapleader = " "
    imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
    nnoremap <leader>/ :tabnext<CR>
    nnoremap <leader>z :tabprevious<CR>
    nnoremap <leader>s :VimShell<CR>
    nnoremap <C-S-p> :Files<CR>
    nnoremap <leader>p :Files<CR>
    nnoremap <C-p> :GitFiles<CR>
    let g:vimshell_prompt_expr =
    \ 'escape(fnamemodify(getcwd(), ":t")."/λ", "\\[]()?! ")." "'
    let g:vimshell_prompt_pattern = '^\%(\f\|\\.\)\+λ '
    let g:vimshell_force_overwrite_statusline = 1
    '';
    extraLuaConfig = ''

    local lsp = require('lsp-zero')
    local cmp = require('cmp')
    local cmp_select = { behavior = cmp.SelectBehavior.Select }
    local cmp_action = require('lsp-zero').cmp_action()

    local cmp_mappings = cmp.mapping.preset.insert({
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-f>'] = cmp_action.luasnip_jump_forward(),
      ['<C-b>'] = cmp_action.luasnip_jump_backward(),
      ['<C-u>'] = cmp.mapping.scroll_docs(-4),
      ['<C-d>'] = cmp.mapping.scroll_docs(4),
      ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
      ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
      ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    })
    cmp_mappings['<Tab>'] = nil
    cmp_mappings['<S-Tab>'] = nil

    cmp.setup({
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      mapping = cmp_mappings,
      snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body)
        end,
      },
      sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
      },
    })

    lsp.on_attach(function(_, bufnr)
      local opts = { buffer = bufnr, remap = false }
      vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
      vim.keymap.set("n", "<F12>", function() vim.lsp.buf.definition() end, opts)
      vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
      vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
      vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
      vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
      vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
      vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
      vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
      vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
      vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
    end)

    lsp.setup()

    require('lazy-lsp').setup {
      prefer_local = true,
    }
    '';
  };
}
