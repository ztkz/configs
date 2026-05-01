local meta = require("config.meta")

local function extend_unique(list, values)
  local seen = {}
  for _, value in ipairs(list) do
    seen[value] = true
  end

  for _, value in ipairs(values) do
    if not seen[value] then
      table.insert(list, value)
      seen[value] = true
    end
  end
end

return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    dependencies = meta.is_enabled() and { "meta.nvim" } or {},
    opts = function(_, opts)
      opts.fuzzy = opts.fuzzy or {}
      opts.fuzzy.prebuilt_binaries = opts.fuzzy.prebuilt_binaries or {}
      opts.fuzzy.prebuilt_binaries.extra_curl_args = meta.proxy_args()

      if not meta.is_enabled() then
        return
      end

      opts.sources = opts.sources or {}
      opts.sources.default = opts.sources.default or {}
      extend_unique(opts.sources.default, {
        "meta_title",
        "meta_tags",
        "meta_tasks",
        "meta_revsub",
      })
      opts.sources.providers = vim.tbl_deep_extend(
        "force",
        opts.sources.providers or {},
        {
          meta_title = {
            name = "MetaTitle",
            module = "meta.cmp.title",
          },
          meta_tags = {
            name = "MetaTags",
            module = "meta.cmp.tags",
          },
          meta_tasks = {
            name = "MetaTasks",
            module = "meta.cmp.tasks",
          },
          meta_revsub = {
            name = "MetaRevSub",
            module = "meta.cmp.revsub",
          },
        }
      )
    end,
  },
}
