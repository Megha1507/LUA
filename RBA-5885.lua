--[[ 
AUTHOR : IQUADRA
Ticket : RBA-5885
Customer: NA
Build:23.0.6-0020_KP4
Schemes: Common tags for all scheme
Description: Add Tag 57 to the encrypted data block
]]--
------------------------------------ START : Common methods ------------------------------
function writeResult(resultList)
local file = io.open("D:\\LUA\\LUA_Scripts\\RBA-5885 results .txt","w")
for id, result in pairs(resultList) do
file:write(id.." : "..result.." \n")
end
file:close()
end

--This function is used to compare the expected and actual values of the test case and return the test result as either 'PASS' /'FAIL'
function validateResult(expected, actual)
if expected == actual then
result = "Pass"
else 
result = "Fail"
end
return result
end

function sendOfflineOnlineMessages()
send("00.0000")
send("01.00000000")
end

function sendAmount()
send("14.01")
send("13.1025")
send("04.1B800")
receive("04.0B800")
end

function OndemandValidation()
send("29.00000398")
actual_398=receive("")
actual_398=string.sub(actual_398,1,4)
send("29.00000399")
actual_399=receive("")
actual_399=string.sub(actual_399,1,4)
send("29.00000400")
actual_400=receive("")
actual_400=string.sub(actual_400,1,4)
if ((actual_398=='29.2') and (actual_399=='29.2') and(actual_400=='29.2'))then
	OndemandValidationResult="Pass"
	else
	OndemandValidationResult="Fail"
	end
return OndemandValidationResult	
end

function EMV_Byte (byte)
    byte = tonumber(byte)
    if (not byte) then return nil end

    return (byte - 1)               -- EMV tag bytes are 1-based
end



-- returns EMV tag data from EMV message string
--      msg       (complete) EMV message with tags
--      tag        specified EMV tag
--
--   returns :
--      EMV tag data, if found in EMV message; 
--      nil,          otherwise

function EMV_GetTagData (msg, tag)
    local tagData   = nil
    local tagIxLen  = EMV_GetTagIndexLength(msg, tag)
    local tagIxData = EMV_GetTagIndexData  (msg, tag)

    if (tagIxLen and tagIxData) then
        local tagLen_str = string.sub(msg, tagIxLen, tagIxData - (2 * string.len(EMV_TAG_SEP)))
        if (tagLen_str) then
            local tagLen = tonumber(tagLen_str, 16)
            if (tagLen > 0) then
                local tagDataType = string.sub(msg,  tagIxData, tagIxData)
                -- get EMV ASCII tag data
                    if ((tagDataType == "A") or 
                        (tagDataType == "a")) then
                      tagData     = string.sub(msg, (tagIxData + string.len(EMV_TAG_SEP)), (tagIxData +      tagLen))

                -- get EMV  hex  tag data
                elseif ((tagDataType == "H") or 
                        (tagDataType == "h")) then
                      tagData     = string.sub(msg, (tagIxData + string.len(EMV_TAG_SEP)), (tagIxData + (2 * tagLen)))

                end
            end
        end
    end

    return tagData
end


-- returns EMV tag data byte from EMV message string
--      msg            (complete) EMV message with tags
--      tag             specified EMV hex data tag
--      byte           (optional) EMV hex data tag byte (1-based)
--
--   returns :
--      EMV tag data byte, if found in EMV message; 
--      EMV tag data,      if byte *NOT* specified; 
--      nil,               otherwise

function EMV_GetTagDataByte_str           (msg, tag, byte)
    return   GetHexDataByte(EMV_GetTagData(msg, tag), EMV_Byte(byte))
end

function EMV_GetTagDataByte_nbr           (msg, tag, byte)
    local byteVal = EMV_GetTagDataByte_str(msg, tag, byte)
    if   (byteVal) then
          byteVal = tonumber(byteVal, 16)
    end
    return byteVal
end


-- returns byte from hex-ASCII data
--      data         hex-ASCII data
--      byte           0-based data byte
--
--   returns :
--      data byte, if found in data; 
--      nil,       otherwise

function GetHexDataByte (data, byte)
    local dataByte = nil

    if (data) then
        if (byte) then
            local byte_actual = tonumber(byte)
            if   (byte_actual and (byte_actual >= 0)) then
                local dataIxByteStart = (byte_actual * 2) + 1
                local dataIxByteEnd   = (byte_actual * 2) + 2
                local dataLen         =  string.len(data)
                if   (dataLen >= dataIxByteEnd) then
                      dataByte = string.sub(data, dataIxByteStart, dataIxByteEnd)
                end
            end
        else
            dataByte = data
        end
    end

    return dataByte
end



-- returns specified index for EMV tag from EMV message string
--      msg         (complete) EMV message with tags
--      tag          specified EMV tag
--
--   returns :
--      specified index for EMV tag, if found in EMV message; 
--      nil,                         otherwise

EMV_TAG_SEP = ":"

function EMV_GetTagIndex  (msg, tag)
    if (msg and tag) then
        return string.find(msg, tag, 1, true)
    else
        return nil
    end
end

function EMV_GetTagIndexLength         (msg, tag)
    local tagIx       = EMV_GetTagIndex(msg, tag)
    local tagIxLen    = nil

    if (tagIx) then
            tagIxLen  = string.find(msg, EMV_TAG_SEP, tagIx,    true)
        if (tagIxLen) then
            tagIxLen  = tagIxLen  + string.len(EMV_TAG_SEP)
        end
    end

    return tagIxLen
end

function EMV_GetTagIndexData                 (msg, tag)
    local tagIxLen    = EMV_GetTagIndexLength(msg, tag)
    local tagIxData   = nil

    if (tagIxLen) then
            tagIxData = string.find(msg, EMV_TAG_SEP, tagIxLen, true)
        if (tagIxData) then
            tagIxData = tagIxData + string.len(EMV_TAG_SEP)
        end
    end

    return tagIxData
end


function verifyDevice()
send("29.00000255")
deviceID=receive("29.20000255.*")
deviceID=string.sub(deviceID,12,14)
return deviceID
end

resultList={} --This 'resultList' table is used to store the execution result of each test as PASS /FAIL.

------------------------------------- START : TC_ID : RBA-5885------------------------------------------

TC_ID='RBA-5885'
send("00.")
send("00.")
offlineResp=receive("")
send("60.8[GS]1[GS]9[FS]")
actual1=receive("")
send("01.00000000")
onlineResp=receive("")
wait(2000)
send("14.01")
echo(TC_ID.."- To validate Tag 57 and 9F20 please use Mastercard Test card".."\nSteps:".."\n1.please insert EMV card")
send("13.1200")
receive("33.02.*")
send("04.1B1200")
receive("04..*")
send("13.1200")
dialog(true)

msg3305      = receive("33.05.*")
array = {"T57", "9F20"}
failedList = {}
for key,tag in ipairs(array) 
do
 tag_actual   = EMV_GetTagData(msg3305, tag)
 tag_actual   = tostring(tag_actual)
 if (tag_actual == "nil") then
	testResult="Fail"
  
table.insert(resultList,"|"..testResult.."|"..tag.."|"..tag_actual)
table.insert(failedList, tag)
writeResult(resultList)
else 

testResult="Pass"
table.insert(resultList,"|"..testResult.."|"..tag.."|"..tag_actual)
writeResult(resultList)
end
end

if next(failedList) == nil then
echo("Tags are present in 33.05 message response")
else
strFailed = "Tags not present are : "

        for key,tag in ipairs(failedList) 
        do
                strFailed = strFailed..tag..","
        end
        table.insert(resultList,strFailed)
        writeResult(resultList)
--echo(strFailed.."\n".."Rest of the Tags are Present")
end
--This is the logic to print all the Test cases result(dictionary) in a message box in the end
final_result=""

for i = 1 , #resultList do
    final_result=final_result.."\n"..resultList[i]
end

echo(final_result)