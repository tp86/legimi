local function withfile(filename, mode)
  return function(handler)
    local file = assert(io.open(filename, mode))
    local ok, err = pcall(handler, file)
    file:close()
    if not ok then
      error(err)
    end
  end
end

local function formatbook(book)
  return string.format("%7d: \"%s\", %s, downloaded: %q",  book.id, book.title, book.author, book.downloaded)
end

local function printbs(bytes)
  for b = 1, #bytes, 16 do
    local chunk = table.pack(bytes:byte(b, b + 15))
    local len = #chunk
    print(string.format(string.rep("%02x ", len), table.unpack(chunk)))
  end
end

local function ranges(total, size)
  size = size or 81920
  local next = 0
  return function()
    if next > total then
      return nil
    end
    local from, to = next, math.min(next + size - 1, total)
    next = to + 1
    return from, to
  end, nil, next
end

return {
  withfile = withfile,
  formatbook = formatbook,
  printbs = printbs,
  ranges = ranges,
}
