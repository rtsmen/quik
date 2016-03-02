p_classcode = "SPBFUT"
p_seccode = "SiH6"
is_run = true
count = 1

function main()

    while is_run do
        sleep(1000)
    end
end

function OnStop(stop_flag)
    is_run = false
    l_file:close()
end

l_file = io.open("C:" .. tostring(count) .. ".txt", "w")

function OnQuote(class_code, sec_code)
    if class_code == p_classcode and sec_code == p_seccode then
        tb = getQuoteLevel2(class_code, sec_code)

        l_file:write(tostring(tb.offer[1].price) .. ";  " ..
                tostring(tb.offer[1].quantity) .. ";  " .. os.date("%X, дата: %x").. "\n")
                
    end
end
