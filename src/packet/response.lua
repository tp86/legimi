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
responses.booklist = {
  type = 28,
}
local bookitem = {
  publisher = 0,
  language = 1,
  categoryname = 2,
  categorydescription = 3,
  publishdate = 4,
  issuename = 5,
  downloadurl = 6,
  categoryid = 7,
  contenttype = 8,
  hybrid = 9,
  id = 10,
  name = 11,
  size = 12,
  version = 13,
  description = 14,
  unlimited = 15,
  drm = 16,
  drmkey = 17,
  drmiv = 18,
  legimipagecount = 19,
  linkedbookid = 20,
  isaudioavailable = 21,
  audiovoicename = 22,
  audioisartificial = 23,
  audioduration = 24,
  linkedaudioduration = 25,
  linkedaudiovoice = 26,
  linkedaudioisartificial = 27,
  linkedaudioid = 28,
  wordscount = 29,
  isalreadydownloaded = 30,
  coverurl = 31,
  isintrash = 32,
  playercoverurl = 33,
  nextpagetoken = 34,
}
responses.booklist.format = serializer.array(
  {
    serializer.byte, -- document type (assert == 7 (unlimited document list item))
    serializer.int, -- length
    serializer.long, -- id (unused)
    serializer.str, -- name (unused)
    serializer.int, -- size (unused)
    serializer.long, -- version (unused)
    serializer.str, -- desc (unused)
    serializer.dict {
      [bookitem.description] = serializer.str,
      [bookitem.id] = serializer.lenlong,
      [bookitem.name] = serializer.str,
      [bookitem.size] = serializer.lenint,
      [bookitem.version] = serializer.lenlong,
      [bookitem.publisher] = serializer.str,
      [bookitem.language] = serializer.str,
      [bookitem.categoryname] = serializer.str,
      [bookitem.categorydescription] = serializer.str,
      [bookitem.issuename] = serializer.str,
      [bookitem.downloadurl] = serializer.str,
      [bookitem.publishdate] = serializer.lenlong,
      [bookitem.categoryid] = serializer.lenlong,
      [bookitem.contenttype] = serializer.lenint,
      [bookitem.hybrid] = serializer.lenbyte,
      [bookitem.unlimited] = serializer.lenbyte,
      [bookitem.drm] = serializer.lenbyte,
      [bookitem.drmkey] = serializer.str,
      [bookitem.drmiv] = serializer.str,
      [bookitem.legimipagecount] = serializer.lenint,
      [bookitem.wordscount] = serializer.lenlong,
      [bookitem.isalreadydownloaded] = serializer.lenbyte,
      [bookitem.linkedbookid] = serializer.lenlong,
      [bookitem.linkedaudioid] = serializer.lenlong,
      [bookitem.isaudioavailable] = serializer.lenbyte,
      [bookitem.linkedaudioisartificial] = serializer.lenbyte,
      [bookitem.linkedaudiovoice] = serializer.str,
      [bookitem.linkedaudioduration] = serializer.lenlong,
      [bookitem.audiovoicename] = serializer.str,
      [bookitem.audioisartificial] = serializer.lenbyte,
      [bookitem.isintrash] = serializer.lenbyte,
      [bookitem.audioduration] = serializer.lenlong,
      [bookitem.coverurl] = serializer.str,
      [bookitem.playercoverurl] = serializer.str,
      [bookitem.nextpagetoken] = serializer.str,
    }
  }
)

local types = {
  [responses.auth.type] = responses.auth,
  [responses.booklist.type] = responses.booklist,
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

local function parse(data)
  local pkt = packet.read(data)
  local type, content = pkt.type, pkt.content
  local response = types[type]
  if response then
    return serializer.unpack(content, response.format)
  else
    error("cannot find response type " .. type)
  end
end

return {
  auth = {
    parse = parseauthresp,
    sessionid = getsessionid,
  },
  parse = parse,
}
