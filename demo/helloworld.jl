# Hello world gtk-server demo in Julia
#

using GtkServer

gtk_init()

gtk_send("gtk_init NULL NULL")
win = gtk_send("gtk_window_new 0")
gtk_send("gtk_window_set_title $win 'Julia GTK-Server demo'")
gtk_send("gtk_window_set_default_size $win 400 200")
tbl = gtk_send("gtk_table_new 10 10 1")
gtk_send("gtk_container_add $win $tbl")
info = gtk_send("gtk_button_new_with_label 'Click here!'")
gtk_send("gtk_table_attach_defaults $tbl $info 1 4 1 9")
but = gtk_send("gtk_button_new_with_label '...or click to quit.'")
gtk_send("gtk_table_attach_defaults $tbl $but 6 9 1 9")
gtk_send("gtk_widget_show_all $win")
dia = gtk_send("u_dialog Information '\"Hello, World!\"' 200 130")

# Main loop
event=0
while true
    event = gtk_send("gtk_server_callback WAIT")
    # The user clicked on the Hello World button.
    if event == dia
        gtk_send("gtk_widget_hide $dia")
    # The user clicked to see the dialog.
    elseif event == info
        gtk_send("gtk_widget_show_all $dia")
    # The user click on the quit button.
    elseif event == but || event == win
        gtk_exit()
        break
    end
end
