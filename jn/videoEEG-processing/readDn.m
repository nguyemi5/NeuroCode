function dn = readDn(dateStr)
 dn = datetime(2000+str2num(dateStr(1:2)), str2num(dateStr(3:4)), str2num(dateStr(5:6)), ...
        str2num(dateStr(8:9)), str2num(dateStr(10:11)), str2num(dateStr(12:13))); 
end

