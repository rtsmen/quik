is_run=true
count=1
function main()
      while is_run do
            sleep(2000)
            message("Hello, World! №"..tostring(count),1)
            count=count+1
      end
end
function OnStop(stop_flag)
      is_run=false
end
