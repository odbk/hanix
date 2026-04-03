{ pkgs, ... }:

{
  programs.nixvim = {
    enable = true;
    performance.lazyLoader.enable = false;

    # ── Colorscheme ────────────────────────────────────────────
    colorschemes.catppuccin = {
      enable = true;
      settings.flavour = "mocha";
    };

    # ── Opciones globales ──────────────────────────────────────
    opts = {
      number         = true;
      relativenumber = true;
      signcolumn     = "yes";
      tabstop        = 2;
      shiftwidth     = 2;
      expandtab      = true;
      wrap           = false;
      ignorecase     = true;
      smartcase      = true;
      termguicolors  = true;
      scrolloff      = 8;
      updatetime     = 250;
    };

    # ── Leader ────────────────────────────────────────────────
    globals.mapleader = " ";

    # ── Keymaps ───────────────────────────────────────────────
    keymaps = [
      # nvim-tree
      { mode = "n"; key = "<leader>e"; action = "<cmd>NvimTreeToggle<CR>"; options.desc = "Toggle explorer"; }
      # Telescope (desactivado temporalmente)
      # Buffers
      { mode = "n"; key = "<S-l>"; action = "<cmd>bnext<CR>";     options.desc = "Next buffer"; }
      { mode = "n"; key = "<S-h>"; action = "<cmd>bprevious<CR>"; options.desc = "Prev buffer"; }
      # Splits
      { mode = "n"; key = "<leader>sv"; action = "<cmd>vsplit<CR>"; options.desc = "Split vertical"; }
      { mode = "n"; key = "<leader>sh"; action = "<cmd>split<CR>";  options.desc = "Split horizontal"; }
      # Clear search highlight
      { mode = "n"; key = "<Esc>"; action = "<cmd>nohlsearch<CR>"; }
    ];

    # ── Plugins ───────────────────────────────────────────────
    plugins = {

      # File explorer
      nvim-tree = {
        enable = true;
        settings = {
          renderer.group_empty = true;
          filters.dotfiles = false;
        };
      };

      # Statusline
      lualine = {
        enable = true;
        settings.options = {
          theme = "catppuccin";
          component_separators = { left = ""; right = ""; };
          section_separators   = { left = ""; right = ""; };
        };
      };

      # Fuzzy finder — telescope desactivado temporalmente (bug nixvim/luarocks plenary)
      # telescope.enable = true;

      # Syntax highlighting
      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable    = true;
          ensure_installed = [
            "bash" "c" "cpp" "json" "lua" "nix"
            "python" "rust" "toml" "yaml"
          ];
        };
      };

      # Completions
      cmp = {
        enable = true;
        settings = {
          sources = [
            { name = "nvim_lsp"; }
            { name = "luasnip"; }
            { name = "buffer"; }
            { name = "path"; }
          ];
          mapping = {
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-e>"     = "cmp.mapping.abort()";
            "<CR>"      = "cmp.mapping.confirm({ select = true })";
            "<Tab>"     = "cmp.mapping(cmp.mapping.select_next_item(), {'i','s'})";
            "<S-Tab>"   = "cmp.mapping(cmp.mapping.select_prev_item(), {'i','s'})";
          };
          snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";
        };
      };

      # Snippets (requerido por cmp)
      luasnip.enable = true;
      cmp_luasnip.enable = true;

      # LSP
      lsp = {
        enable = true;
        servers = {
          lua_ls.enable     = true;
          bashls.enable     = true;
          nixd.enable       = true;
          pyright.enable    = true;
          clangd.enable     = true;
        };
      };

      # Git signs en el gutter
      gitsigns = {
        enable = true;
        settings.signs = {
          add.text          = "│";
          change.text       = "│";
          delete.text       = "_";
          topdelete.text    = "‾";
          changedelete.text = "~";
        };
      };

      # Hints de teclas
      which-key.enable = true;

      # Auto-pares
      nvim-autopairs.enable = true;

      # Comentarios
      comment.enable = true;

      # Bufferline (pestañas de buffers)
      bufferline = {
        enable = true;
        settings.options = {
          separator_style = "slant";
          show_buffer_close_icons = false;
          show_close_icon = false;
        };
      };

      # Indent guides
      indent-blankline.enable = true;

      # Iconos (requerido por telescope, nvim-tree, alpha, bufferline)
      web-devicons.enable = true;

      # Dashboard de inicio
      alpha = {
        enable = true;
        theme = "dashboard";
      };
    };
  };
}
