local function printbs(bytes)
  for b = 1, #bytes, 16 do
    local chunk = table.pack(bytes:byte(b, b + 15))
    local len = #chunk
    print(string.format(string.rep("%02x ", len), table.unpack(chunk)))
  end
end

return {
  printbs = printbs,
}
