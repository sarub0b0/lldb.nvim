let start_cmd = 'lldb'

function! lldb#prompt(ch, msg)
    echo msg
endfunction

function! lldb#start()
    let job = job_start(start_cmd, {'callback': 'lldb#prompt'})

endfunction
