<!-- =============================
     ABOUT
    ============================== -->

\begin{:section, title="About GtkServer", name="About"}

GtkServer.jl is a Julia front-end for [gtk-server](https://www.gtk-server.org/intro.html), a stream-oriented interface to GTK. With GtkServer.jl, it is very easy to add simple GUIs to Julia programs.

GtkServer.jl started life in 2012, when no other GUI options existed for Julia (see the original repository: [https://bitbucket.org/mbaz/gtkjl/src/default/](https://bitbucket.org/mbaz/gtkjl/src/default/)). After re-discovering this code in 2020, I decided to dust it off and polish it a bit. Even though [Gtk.jl](https://github.com/JuliaGraphics/Gtk.jl) essentially makes GtkServer.jl obsolete, it might still be useful in [platforms where Gtk.jl is slow](https://github.com/JuliaGraphics/Gtk.jl/issues/325).

\end{:section}

<!-- =============================
     GETTING STARTED
     ============================== -->
\begin{:section, title="Getting started"}

In order to get started, install `gtk-server` on your platform; there are instructions [here](https://www.gtk-server.org/download.html). If there is no binary package for your platform, you may have to compile it yourself. This is very easy, at least on Linux; it's just a matter of running the usual `./configure && make && sudo make install` routine.

Once `gtk-server` is installed, add the package (with **Julia ≥ 1.0.5**), and get a nice button to click on with:

```julia-repl
using GtkServer
gtk_init()  # Initialize gtk-server
gtk_send("gtk_init NULL NULL")
win = gtk_send("gtk_window_new 0")
ok = gtk_send("gtk_button_new_with_label 'OK'")
tbl = gtk_send("gtk_table_new 3 3 1")
gtk_send("gtk_container_add $win $tbl")
gtk_send("gtk_table_attach_defaults $tbl $ok 1 2 1 2")
gtk_send("gtk_widget_show_all $win")
while true
    event = gtk_send("gtk_server_callback WAIT")
    if event == ok
        break
    end
end
gtk_exit()  # shut gtk-server down
```

\\

The `gtk_init()` call starts a gtk-server instance and establishes a two-way communication channel to it via stdin/stdout. `gtk_send` sends a command to `gtk-server`; the response is either `"ok\n"`, or a widget or event id. The call `gtk_send("gtk_server_callback WAIT")` blocks until there is an event in the GUI, and returns the event. Finally, `gtk_exit()` shuts down the server and tears down the communication channel.

\end{:section}

<!-- =============================
     DEMOS
     ============================== -->
\begin{:section, title="Included demos"}

The package includes three demos (in the folder `demos/`). These can be run by doing `include("demo/<name>")` from the package source directory.

* `helloworld.jl` is a simple demo with a few buttons.

\figure{path="/assets/GtkServerHelloWorldDemo.png"}

* `fourier.jl` is an iteractive demo, using sliders, of the Fourier analysis of a sine wave. It relies on the plotting package [Gaston.jl](https://github.com/mbaz/Gaston.jl), but it should be pretty easy to adapt it to other packages. After `include`ing the code, run `demo()`.

\figure{path="/assets/GtkServerFourierDemo.gif"}

* `mandelbrot.jl` is a (slow!) Mandelbrot set viewer:

\figure{path="/assets/mandel.png"}

You can even even specify the `x` and `y` ranges to plot, the number of iterations and radius,  and the color palette. See the code for details.

\end{:section}

\begin{:section, title="Contributing"}

Issues and pull requests are welcome. I am particulary interested in:

* Instructions to install `gtk-server` on Windows, MacOS and different Linux distributions.

* Improvement to the Mandelbrot demo, to make it faster and/or more flexible.

* More demos! An ideal demo is short, well commented, and shows how to use one or more GTK features.

\end{:section}
