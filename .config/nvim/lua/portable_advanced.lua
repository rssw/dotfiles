local M = {}

local function req(name)
  local ok, mod = pcall(require, name)
  if ok then
    return mod
  end
  return nil
end

local function map(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs, opts or {})
end

function M.attach_dap_repl()
  map('i', '<C-\\><C-\\>', '<C-c>', { buffer = true, silent = true })
  map('i', '<C-h>', '<C-c>:TmuxNavigateLeft<CR>', { buffer = true, silent = true })
  map('i', '<C-j>', '<C-c>:TmuxNavigateDown<CR>', { buffer = true, silent = true })
  map('i', '<C-k>', '<C-c>:TmuxNavigateUp<CR>', { buffer = true, silent = true })
  map('i', '<C-l>', '<C-c>:TmuxNavigateRight<CR>', { buffer = true, silent = true })
  map('i', '<C-d>', 'exit<CR>', { buffer = true, silent = true })
end

local function buf_is_big(bufnr)
  local max_filesize = 100 * 1024
  local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
  return ok and stats and stats.size > max_filesize or false
end

local function setup_dap()
  local dap = req('dap')
  local dapui = req('dapui')
  if not dap or not dapui then
    return
  end

  dapui.setup({
    mappings = {
      edit = {},
      open = {},
      remove = {},
      repl = {},
      toggle = {},
    },
  })

  dap.listeners.after.event_initialized['dapui_config'] = function()
    dapui.open()
  end

  local dap_python = req('dap-python')
  if dap_python then
    dap_python.setup('python')
  end

  local dap_go = req('dap-go')
  if dap_go then
    dap_go.setup()
  end

  dap.adapters.perl = {
    type = 'executable',
    command = 'perl-debugger',
  }

  dap.configurations = {
    python = {
      {
        type = 'python',
        request = 'launch',
        name = 'Launch file',
        program = '${file}',
        pythonPath = 'python',
      },
    },
    go = {
      {
        type = 'go',
        name = 'Debug Package',
        request = 'launch',
        program = '${fileDirname}',
      },
    },
    perl = {
      {
        type = 'perl',
        request = 'launch',
        name = 'Launch Perl',
        program = '${workspaceFolder}/${relativeFile}',
      },
    },
  }

  vim.api.nvim_create_user_command('RunScriptWithArgs', function(t)
    local args = vim.fn.substitute(vim.fn.expand(t.args), '\n', ' ', 'g')
    local approval = vim.fn.confirm(
      'Will try to run:\n    ' .. vim.bo.filetype .. ' ' .. vim.fn.expand('%') .. ' ' .. args .. '\n\nDo you approve? ',
      '&Yes\n&No',
      1
    )
    if approval == 1 then
      dap.run({
        type = vim.bo.filetype,
        request = 'launch',
        name = 'Launch file with custom arguments (adhoc)',
        program = '${file}',
        args = vim.split(args, ' ', { trimempty = true }),
      })
    end
  end, { complete = 'file', nargs = '*' })

  map('n', '<leader>R', ':RunScriptWithArgs ')
  map('n', '<leader>C', dapui.close, { desc = 'DAP: Close UI' })
  map('n', '<leader>c', dap.continue, { desc = 'DAP: Continue' })
  map('n', '<leader>o', dap.step_over, { desc = 'DAP: Step Over' })
  map('n', '<leader>s', dap.step_into, { desc = 'DAP: Step Into' })
  map('n', '<leader>u', dap.step_out, { desc = 'DAP: Step Out' })
  map('n', '<leader>T', dap.terminate, { desc = 'DAP: Terminate' })
  map('n', '<leader>b', dap.toggle_breakpoint, { desc = 'DAP: Toggle Breakpoint' })
  map('n', '<leader>B', function()
    dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
  end, { desc = 'DAP: Breakpoint on condition' })
  map('n', '<leader>lp', function()
    dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
  end, { desc = 'DAP: Log Point message' })
  map('n', '<leader>dr', dap.repl.toggle, { desc = 'DAP.REPL: toggle' })
  map('n', '<leader>dl', dap.run_last, { desc = 'DAP: Run Last' })
  if dap_python then
    map('n', '<leader>dn', dap_python.test_method, { desc = 'DAP_PYTHON: Test Method' })
    map('n', '<leader>df', dap_python.test_class, { desc = 'DAP_PYTHON: Test Class' })
    map('v', '<leader>ds', dap_python.debug_selection, { desc = 'DAP_PYTHON: Debug Selection' })
  end
end

local function setup_cmp_and_lsp()
  local cmp = req('cmp')
  if not cmp then
    return
  end

  local function has_words_before()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
  end

  local function feedkey(key, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
  end

  cmp.setup({
    preselect = cmp.PreselectMode.None,
    snippet = {
      expand = function(args)
        vim.fn['vsnip#anonymous'](args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = false }),
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif vim.fn['vsnip#available'](1) == 1 then
          feedkey('<Plug>(vsnip-expand-or-jump)', '')
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<S-Tab>'] = cmp.mapping(function()
        if cmp.visible() then
          cmp.select_prev_item()
        elseif vim.fn['vsnip#jumpable'](-1) == 1 then
          feedkey('<Plug>(vsnip-jump-prev)', '')
        end
      end, { 'i', 's' }),
    }),
  })

  vim.api.nvim_create_autocmd('BufReadPre', {
    callback = function(t)
      if not buf_is_big(t.buf) then
        cmp.setup.buffer({
          sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'nvim_lsp_signature_help' },
          }, {
            { name = 'vsnip' },
            { name = 'path' },
            { name = 'treesitter' },
          }),
        })
      end
    end,
  })

  vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(t)
      if buf_is_big(t.buf) then
        for _, client in pairs(vim.lsp.get_active_clients({ bufnr = t.buf })) do
          vim.defer_fn(function()
            vim.lsp.buf_detach_client(t.buf, client.id)
            print('Detaching client ' .. client.name .. ' because buffer ' .. vim.fn.bufname(t.buf) .. ' is too big')
          end, 10)
        end
      end
    end,
  })

  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({ { name = 'path' } }, { { name = 'cmdline' } }),
  })
  cmp.setup.filetype('zsh', {
    sources = cmp.config.sources({ { name = 'zsh' } }, {
      { name = 'vsnip' },
      { name = 'path' },
    }),
  })

  local lspconfig = req('lspconfig')
  local cmp_lsp = req('cmp_nvim_lsp')
  if not lspconfig or not cmp_lsp then
    return
  end

  local servers_list = {
    'texlab', 'clangd', 'jedi_language_server', 'matlab_ls', 'gopls', 'rls',
    'svls', 'nixd', 'vhdl_ls', 'cmake', 'arduino_language_server',
    'autotools_ls', 'cssls', 'eslint', 'dockerls', 'bashls', 'vimls', 'yamlls',
  }
  local capabilities = cmp_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
  local default_setup_settings = {
    autostart = true,
    capabilities = capabilities,
    on_attach = function(_, bufnr)
      local bufopts = { noremap = true, silent = true, buffer = bufnr }
      map('n', 'gD', vim.lsp.buf.declaration, bufopts)
      map('n', 'gd', vim.lsp.buf.definition, bufopts)
      map('n', 'gi', vim.lsp.buf.implementation, bufopts)
      map('n', 'gs', vim.lsp.buf.signature_help, bufopts)
      map('n', 'gt', vim.lsp.buf.type_definition, bufopts)
      map('n', 'gr', vim.lsp.buf.references, bufopts)
      map('n', '<leader>r', vim.lsp.buf.rename, bufopts)
      map('n', '<leader>f', vim.lsp.buf.format, bufopts)
      map('n', '[q', vim.diagnostic.goto_prev, bufopts)
      map('n', ']q', vim.diagnostic.goto_next, bufopts)
      map('n', '<space>q', vim.diagnostic.setloclist, bufopts)
    end,
  }
  for _, server in ipairs(servers_list) do
    if lspconfig[server] then
      lspconfig[server].setup(default_setup_settings)
    end
  end
  if lspconfig.perlnavigator then
    local perl_setup_settings = vim.tbl_extend('force', default_setup_settings, {
      cmd = { 'perlnavigator', '--stdio' },
    })
    lspconfig.perlnavigator.setup(perl_setup_settings)
  end
end

local function setup_fzf()
  local fzf = req('fzf-lua')
  if not fzf then
    return
  end
  fzf.setup({
    buffers = { sort_lastused = false },
    actions = { files = { ['default'] = fzf.actions.file_edit } },
  })
  map({ 'n', 'v', 'i' }, '<C-x><C-f>', function()
    fzf.complete_path({ cmd = "find -maxdepth 2 -mindepth 1 -printf '%P\\n'", previewer = 'builtin' })
  end, { silent = true, desc = 'Fuzzy complete path' })
  map({ 'n', 'v', 'i' }, '<C-x><C-l>', function()
    fzf.complete_line({
      fzf_opts = {
        ['--query'] = vim.fn.shellescape(vim.fn.getbufline(vim.fn.bufnr('%'), vim.fn.line('.'))[1]),
      },
    })
  end, { silent = true, desc = 'Fuzzy complete lines' })
end

local function setup_treesitter()
  local ok, configs = pcall(require, 'nvim-treesitter.configs')
  if not ok then
    return
  end
  configs.setup({
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = { 'python' },
      disable = function(lang, buf)
        if lang == 'nix' or lang == 'vimdoc' then
          return true
        end
        return buf_is_big(buf)
      end,
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
        selection_modes = {
          ['@parameter.outer'] = 'v',
          ['@function.outer'] = 'V',
          ['@class.outer'] = '<c-v>',
        },
        include_surrounding_whitespace = true,
      },
    },
  })
end

local function setup_lualine()
  local lualine = req('lualine')
  if not lualine then
    return
  end
  lualine.setup({
    options = { theme = 'sonokai' },
    tabline = {
      lualine_a = {{ 'buffers', show_filename_only = false }},
      lualine_b = {}, lualine_c = {}, lualine_x = {}, lualine_y = {}, lualine_z = { 'tabs' },
    },
  })
end

local function setup_colorizer()
  local colorizer = req('colorizer')
  if not colorizer then
    return
  end
  colorizer.setup({ 'css', 'vim' })
end

function M.setup()
  setup_dap()
  setup_cmp_and_lsp()
  setup_fzf()
  setup_treesitter()
  setup_lualine()
  setup_colorizer()
end

return M
