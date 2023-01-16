local serializer = require "serializer"
local responses = {}
responses.auth = {
  type = 16386,
  fields = {
    state = 0,
    stateexpirationdate = 1,
    tillstateexpirationseconds = 2,
    servermessage = 3,
    servertimestamp = 4,
    errorid = 5,
    deviceid = 6,
    sessionid = 7,
    packetname = 8,
    token = 9,
    userid = 10,
    userlogin = 11,
    transfermethod = 12,
    recyclesleft = 13,
    maxsmartphonecount = 14,
    maxtabletcount = 15,
    maxeinkcount = 16,
    maxwin8count = 17,
    maindomain = 18,
    externalaccounts = 19,
    legimiusername = 20,
    isactivating = 21,
    sequencenumber = 22,
    wordsleft = 23,
    wordsinitlimit = 24,
    wordsrefillcount = 25,
    wordsrefillprice = 26,
    totaldevicecount = 27,
    canautopurchasewords = 28,
    includesaudio = 29,
    revokedbooks = 30,
    includessingleaudio = 31,
    maxkindlecount = 32,
    maxdownloads = 33,
    downloadsleft = 34,
    islibrary = 35,
    brand = 36,
    isinlastagreementperiod = 37,
    accountimageurl = 38,
    userreferralurl = 39,
    brandcollectionid = 40,
  },
}
responses.auth.format = serializer.dict {
  [responses.auth.fields.state] = serializer.lenshort,
  [responses.auth.fields.stateexpirationdate] = serializer.lenlong,
  [responses.auth.fields.tillstateexpirationseconds] = serializer.lenlong,
  [responses.auth.fields.servermessage] = serializer.str,
  [responses.auth.fields.servertimestamp] = serializer.lenlong,
  [responses.auth.fields.errorid] = serializer.lenshort,
  [responses.auth.fields.sessionid] = serializer.str,
  [responses.auth.fields.packetname] = serializer.str,
  [responses.auth.fields.transfermethod] = serializer.str,
  [responses.auth.fields.recyclesleft] = serializer.lenint,
  [responses.auth.fields.maxsmartphonecount] = serializer.lenint,
  [responses.auth.fields.maxtabletcount] = serializer.lenint,
  [responses.auth.fields.maxeinkcount] = serializer.lenint,
  [responses.auth.fields.maxwin8count] = serializer.lenint,
  [responses.auth.fields.maindomain] = serializer.lenbyte,
  --[responses.auth.fields.externalaccounts] = serializer.array,
  [responses.auth.fields.legimiusername] = serializer.str,
  [responses.auth.fields.isactivating] = serializer.lenbyte,
  [responses.auth.fields.sequencenumber] = serializer.lenlong,
  [responses.auth.fields.wordsleft] = serializer.lenint,
  [responses.auth.fields.wordsinitlimit] = serializer.lenint,
  [responses.auth.fields.wordsrefillcount] = serializer.lenint,
  [responses.auth.fields.wordsrefillprice] = serializer.str,
  [responses.auth.fields.totaldevicecount] = serializer.lenint,
  [responses.auth.fields.canautopurchasewords] = serializer.lenbyte,
  [responses.auth.fields.includesaudio] = serializer.lenbyte,
  --[responses.auth.fields.revokedbooks] = serializer.array { serializer.long },
  [responses.auth.fields.includessingleaudio] = serializer.lenbyte,
  [responses.auth.fields.maxkindlecount] = serializer.lenint,
  [responses.auth.fields.maxdownloads] = serializer.lenint,
  [responses.auth.fields.downloadsleft] = serializer.lenint,
  [responses.auth.fields.islibrary] = serializer.lenbyte,
  [responses.auth.fields.brand] = serializer.str,
  [responses.auth.fields.isinlastagreementperiod] = serializer.lenbyte,
  [responses.auth.fields.accountimageurl] = serializer.str,
  [responses.auth.fields.brandcollectionid] = serializer.lenlong,
}

local packet = require "packet.generic"
local function parseauthresp(data)
  local resp = responses.auth
  local authresp = packet.read(data)
  local parsed = serializer.unpack(authresp.content, resp.format)
  return parsed
end

local function getsessionid(authresp)
  return authresp[responses.auth.fields.sessionid]
end

return {
  auth = {
    parse = parseauthresp,
    sessionid = getsessionid,
  }
}
