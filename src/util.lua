local function withfile(filename, mode)
  return function(handler)
    local file = io.open(filename, mode)
    handler(file)
    if file then
      file:close()
    end
  end
end

return {
  withfile = withfile,
}
