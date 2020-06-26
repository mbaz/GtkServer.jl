module GtkServer

export gtk_init, gtk_send, gtk_exit

struct Pipes
    pin  :: Pipe
    pout :: Pipe
end

# Internal Gtk-Server state
struct State
    pipes    :: Pipes
    process  :: Union{Base.Process, Nothing}
    nullmode :: Bool
end

function gtk_init(; nullmode = false, logfile::String = "")
    # Start gtk-server and define pipes
    pin = Pipe()
    pout = Pipe()
    try
        success(`gtk-server`)
        # set up gtk-server command
        if logfile != ""
            cmd = `gtk-server -stdin -log=$logfile`
        else
            cmd = `gtk-server -stdin`
        end
        # execute gtk-server and set up communtb vert term julitb vert term juliacation pipes
        gtkproc = run(pipeline(cmd, stdin = pin, stdout = pout), wait = false)
        process_running(gtkproc) || error("There was a problem starting gtk-server")
        close(pout.in)
        close(pin.out)
        Base.start_reading(pout.out)
        global state = State(Pipes(pin, pout), gtkproc, false)
    catch
        @warn "gtk-server is not available on this platform;\nGtkServer.jl is operating in null mode."
        global state = State(Pipes(pin,pout), nothing, true)
    end
    return state
end

function gtk_send(s::AbstractString)::String
    global state

    if !state.nullmode
        write(state.pipes.pin, s)
        flush(state.pipes.pin)
        yield()
        response = String(readavailable(state.pipes.pout))
    else
        @warn "GtkServer is in null mode; no operation has been performed."
        response = ""
    end
    return response
end

function gtk_exit()::String
    global state

    if !state.nullmode
        response = gtk_send("gtk_server_exit")
        close(state.pipes.pin)
        close(state.pipes.pout)
    else
        @warn "GtkServer is in null mode; no operation has been performed."
        response = ""
    end
    return response
end

end # module
