p_classcode="TQBR" --��� ������
p_seccode="LKOH" --��� �����������
is_run=true
count=1
function main()
      while is_run do
            sleep(2000)
      end
end
function OnStop(stop_flag)
      is_run=false
end
function OnQuote(class_code, sec_code)
      if class_code==p_classcode and sec_code==p_seccode then
            l_file=io.open("G:"..tostring(count)..".txt", "w")
            tb=getQuoteLevel2(class_code, sec_code)
           
            l_file:write("BID:\n")
            for i=1,2,1 do --tb.bid_count
                  l_file:write(tostring(tb.bid[i].price)..";  "..
                        tostring(tb.bid[i].quantity).."\n")
            end
           
            l_file:write("OFFER:\n")
            for i=1,2,1 do --tb.offer_count
                  l_file:write(tostring(tb.offer[i].price)..";  "..
                        tostring(tb.offer[i].quantity).."\n")
            end        
           
            count=count+2 --��������� ������
            l_file:close()
      end
end
