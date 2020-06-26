using GtkServer, Test

s = gtk_init()
if !s.nullmode
    @test begin
        gtk_init()
        gtk_send("gtk_init NULL NULL")
        win = gtk_send("gtk_window_new 0")
        gtk_exit()
    end == "ok\n"
else
    @test begin
        gtk_exit()
    end == ""
end
