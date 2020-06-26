# Draw the Mandelbrot set
#
# Inspired by the gtk-server fractal demo, by Peter van Eerten
#
# Requires the ColorSchemes package

using GtkServer, ColorSchemes

fc(c, z) = z^2 + c

function mandelbrot(c, maxiters, radius)
    iters = 0
    z = 0
    r = 0.0
    while r < radius
        iters += 1
        z = fc(c, z)
        r = abs(z)^2
        iters == maxiters && break
    end
    return iters
end

# The x and y range to plot can be specified as tuples. Also, the maximum number of iterations,
# the radius at which the point is assumed to have escaped, and the palette can also be specified.
function demo(; x = (-2.3, 1), y = (-1.2, 1.2), maxiters = 50, radius = 5.0, palette = :dense)
    # Initialize GtkServer
    gtk_init()
    # Initialize GTK itself
    gtk_send("gtk_init NULL NULL")
    # Create the top-level window, give it a title, size it, center it, and make it non-resizeable
    win = gtk_send("gtk_window_new 0")
    gtk_send("gtk_window_set_title $win 'Julia GTK Mandelbrot Generator'")
    gtk_send("gtk_widget_set_size_request $win 800 650")  # width, height
    gtk_send("gtk_window_set_position $win 1")
    gtk_send("gtk_window_set_resizable $win 0")
    # Create widget to display image
    image = gtk_send("gtk_image_new")
    ebox = gtk_send("gtk_event_box_new")
    gtk_send("gtk_container_add $ebox $image")
    # Create a separator
    sep = gtk_send("gtk_hseparator_new")
    # Create buttons
    draw_btn = gtk_send("gtk_button_new_with_label Draw")
    gtk_send("gtk_widget_set_size_request $draw_btn 75 30")
    clear_btn = gtk_send("gtk_button_new_with_label Clear")
    gtk_send("gtk_widget_set_size_request $clear_btn 75 30")
    exit_btn = gtk_send("gtk_button_new_with_label Exit")
    gtk_send("gtk_widget_set_size_request $exit_btn 75 30")
    # place widgets using boxes
    hbox = gtk_send("gtk_hbox_new 0 0")
    gtk_send("gtk_box_pack_start $hbox $draw_btn 0 0 1")
    gtk_send("gtk_box_pack_start $hbox $clear_btn 0 0 1")
    gtk_send("gtk_box_pack_end $hbox $exit_btn 0 0 1")
    vbox = gtk_send("gtk_vbox_new 0 0")
    gtk_send("gtk_box_pack_start $vbox $ebox 0 0 1")
    gtk_send("gtk_box_pack_start $vbox $sep 0 0 1")
    gtk_send("gtk_box_pack_end $vbox $hbox 0 0 1")
    gtk_send("gtk_container_add $win $vbox")
    # Show all widgets
    gtk_send("gtk_widget_show_all $win")
    # Create an image to display the fractal
    gdkwin = gtk_send("gtk_widget_get_parent_window $image")
    pix = gtk_send("gdk_pixmap_new $gdkwin 799 600 -1")
    gcn = gtk_send("gdk_gc_new $pix")
    gtk_send("gtk_image_set_from_pixmap $image $pix NULL")
    color = gtk_send("gtk_frame_new NULL")
    gtk_send("gdk_color_parse #ffffff $color")
    gtk_send("gdk_gc_set_rgb_bg_color $gcn $color")
    gtk_send("gdk_gc_set_rgb_fg_color $gcn $color")
    gtk_send("gdk_draw_rectangle $pix $gcn 1 0 0 799 600")
    gtk_send("gdk_color_parse #000000 $color")
    gtk_send("gdk_gc_set_rgb_fg_color $gcn $color")
    gtk_send("gtk_widget_queue_draw $image")
    # show all widgets
    gtk_send("gtk_widget_show_all $win")
    gtk_send("gtk_server_callback update")

    # Mandelbrot variables
    X = range(x[1], x[2], length = 799)
    Y = range(y[1], y[2], length = 600)
    maxiters = 50
    radius = 5.0

    # choose palette
    cm = colorschemes[palette]

    # cache colors
    colorcache = Dict{Int, String}()

    # main loop
    loop = true
    px = 0
    py = 0
    while loop
        result = gtk_send("gtk_server_callback wait")
        if result == draw_btn
            for yy in Y
                px = 0
                py += 1
                loop == false && break
                for xx in X
                    px += 1
                    iters = mandelbrot(Complex(xx, yy), maxiters, radius)
                    if haskey(colorcache, iters)
                        pcolor = colorcache[iters]
                    else
                        c = get(cm, iters/maxiters)
                        cr = string(floor(Int,256*c.r), base=16, pad=2)
                        cg = string(floor(Int,256*c.g), base=16, pad=2)
                        cb = string(floor(Int,256*c.b), base=16, pad=2)
                        pcolor = "#$cr$cg$cb"
                        push!(colorcache, iters => pcolor)
                    end
                    gtk_send("gdk_color_parse $pcolor $color")
                    gtk_send("gdk_gc_set_rgb_fg_color $gcn $color")
                    gtk_send("gdk_draw_point $pix $gcn $px $py")
                    result = gtk_send("gtk_server_callback update")
                    if result == exit_btn || result == win
                        loop = false
                        break
                    end
                end
                gtk_send("gtk_widget_queue_draw $image")
                gtk_send("gtk_server_callback update")
            end
        elseif result == clear_btn
            gtk_send("gdk_color_parse #ffffff $color")
            gtk_send("gdk_gc_set_rgb_fg_color $gcn $color")
            gtk_send("gdk_draw_rectangle $pix $gcn 1 0 0 799 600")
            gtk_send("gdk_color_parse #000000 $color")
            gtk_send("gdk_gc_set_rgb_fg_color $gcn $color")
            gtk_send("gtk_widget_queue_draw $image")
        elseif result == exit_btn || result == win
            break
        end
    end
    gtk_exit()
end
