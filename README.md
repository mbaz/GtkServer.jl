GtkServer: A simple front-end to GTK
====================================

[gtk-server](https://www.gtk-server.org/) provides a stream-oriented interface to the GTK library. It may be the easiest way to create simple GUIs for Julia programs.

See the documentation [here]().

To quickly see examples of GtkServer in action, see the [three included demos]().

Tutorial
--------

First, initialize `GtkServer` by loading the package and calling `gtk_init()`.

```
using GtkServer
gtk_init()
```

Then, send commands to GTK using `gtk_send()`. First, set up the GUI:

```
gtk_send("gtk_init NULL NULL")
win = gtk_send("gtk_window_new 0")
gtk_send("gtk_window_set_title $win 'GTK-Server tutorial'")
gtk_send("gtk_window_set_default_size $win 200 100")
tbl = gtk_send("gtk_table_new 10 10 1")
gtk_send("gtk_container_add $win $tbl")
ok = gtk_send("gtk_button_new_with_label 'OK'")
gtk_send("gtk_table_attach_defaults $tbl $ok 1 9 1 9")
gtk_send("gtk_widget_show_all $win")
```

Then, use a loop to catch GTK events:

```
event=0
while true
    event = gtk_send("gtk_server_callback WAIT")
    if event == ok
        break
    end
end
```

Finally, wrap things up with `gtk_exit()`.

This example produces a button like this:


