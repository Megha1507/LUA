--Precondition:
--Device : All
--Communication : USB-CDC/Bluetooth/Ethernet/USB-HID (All)
--Author : Iquadra
--------------------------------------------------------------------------- START : Common methods --------------------------------------------------------------------------
function writeResult(resultList)
local file = io.open("D:\\LUA\\LUA_Scripts\\EMV_Result.txt","w")
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


function EMV_Byte (byte)
    byte = tonumber(byte)
    if (not byte) then return nil end

    return (byte - 1)               -- EMV tag bytes are 1-based
end

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



resultList={} --This 'resultList' table is used to store the execution result of each Tags as PASS /FAIL.

------------------------------------------------ START : EMV_TAGS----------------------------------------------------

--This is an EMV Sale:
send("00.")
send("00.")
echo("Make sure Onguard Encryption is Enabled")
send("60.19[GS]1[GS]1")

send("01.00000000")

wait(1000)
send("14.01")
send("13.1200")
echo("Performed Void transation".."\n Please Insert EMV card")
msg3302      = receive([[^33\.0(2).*]])
tag              = "FF1D"
tagFF1D_actual   = 	EMV_GetTagData(msg3302, tag)
tagFF1D_actual   = tostring(tagFF1D_actual)
if (tagFF1D_actual == "nil") then
    echo ("Tag FF1D is not present")
	testResult_1="Fail"
	table.insert(resultList,"|".."33.02".."|"..testResult_1.."|"..tag.."|"..tagFF1D_actual)

	writeResult(resultList)
else  
    echo ("Tag is Present")
    echo("In 33.02 TagFF1D: "..tagFF1D_actual)
	testResult_1="Pass"	
	table.insert(resultList,"|" .. "33.02".."|"..testResult_1.."|"..tag.."|"..tagFF1D_actual)

	writeResult(resultList)
	
	end
	 
--This is the logic to print all the Test cases result(dictionary) in a message box in the end
final_result=""
for i = 1 , #resultList do
    final_result=final_result.."\n"..resultList[i]
end



