p_classcode = "SPFUT"
p_seccode = "SiH6"
is_run = true
count = 1

l_file = io.open("C:" .. tostring(count) .. ".txt", "w")

function main()

    while is_run do
        sleep(1000)
    end
end

function OnStop(stop_flag)
    is_run = false
    l_file:close()
end

function OnQuote(class_code, sec_code)
    if class_code == p_classcode and sec_code == p_seccode then
        tb = getQuoteLevel2(class_code, sec_code)

        for i = 1, 2, 1 do --tb.offer_count
        l_file:write(tostring(tb.offer[i].price) .. ";  " ..
                tostring(tb.offer[i].quantity) .. ";  " .. os.time().. "\n")
        end
    end
end
