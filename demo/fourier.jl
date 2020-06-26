# Fourier demo with gtk-server
# #
# Note: requires package Gaston for plotting, or adjust the code to work with your
# plotting front-end.

using GtkServer, Gaston, FFTW

# plot
function doplots(t, A, f₀, ϕ, fs)
    s = A.*sin.(2π*f₀*t .+ ϕ)
    S = fftshift(fft(s))./length(s)
    F = fftshift(fftfreq(length(s), fs))

    p1 = plot(t, s, handle = 1,
              Axes(title = "'Sinusoidal in time domain'", xlabel = "'Time (s)'",
                   ylabel = "'Amplitude'", yrange = (-5.5, 5.5), ytics = -6:2:6))
    p2 = plot(F, abs.(S), handle = 2,
              Axes(title = "'Magnitude spectrum'", xlabel = "'Frequency (Hz)'",
                   yrange = (0, 3)))
    p3 = plot(F, angle.(S), handle = 3,
              Axes(title = "'Phase spectrum'", xlabel = "'Frequency (Hz)'",
                   yrange = (-3, 3)))
    P = plot([p1, p2, p3], handle = 4)
    display(P)
end

function demo()
    # Set initial values for amplitude, frequency and phase, and display
    # the sine function.
    fs = 100
    t = 0.0:1.0/fs:1.0
    A = 1.0
    f₀ = 1.0
    ϕ = 0.0

    # Do initial plot with default values
    doplots(t, A, f₀, ϕ, fs)

    # Main program
    # This program interactively plots a sine function in time, and its
    # magnitude and phase spectra. The amplitude, frequency and phase of
    # sine function are selected through three sliders.
    gtk_init()
    # 'win' is a handle (ID number) to the main GUI window.
    gtk_send("gtk_init NULL NULL")
    win = gtk_send("gtk_window_new 0")
    # Set window's title, size and position.
    # Note that the message sent to gtk-server is always a string.
    gtk_send("gtk_window_set_title $win 'Fourier Series Demo'")
    gtk_send("gtk_window_set_default_size $win 300 200")
    gtk_send("gtk_window_set_position $win 1")
    # We'll set our widgets in a table, one widget per row-column combination.
    tbl = gtk_send("gtk_table_new 8 10 0")
    gtk_send("gtk_container_add $win $tbl")
    # Create three labels...
    lblA = gtk_send("gtk_label_new Amplitude:")
    lblF = gtk_send("gtk_label_new Frequency:")
    lblP = gtk_send("gtk_label_new Phase:")
    # and put them in specific position on our table.
    gtk_send("gtk_table_attach_defaults $tbl $lblA 1 3 1 2")
    gtk_send("gtk_table_attach_defaults $tbl $lblF 1 3 3 4")
    gtk_send("gtk_table_attach_defaults $tbl $lblP 1 3 5 6")
    # horizontal separator
    hsep = gtk_send("gtk_hseparator_new")
    gtk_send("gtk_table_attach_defaults $tbl $hsep 1 9 6 7")
    # Some Julia advertisement
    adv = gtk_send("gtk_label_new 'Created with Julia!'")
    gtk_send("gtk_table_attach_defaults $tbl $adv 1 6 7 8")
    # Create (and put on the table) the quit button.
    but = gtk_send("gtk_button_new_from_stock 'gtk-quit'")
    gtk_send("gtk_table_attach_defaults $tbl $but 7 9 7 8")
    # Create three sliders...
    sliA = gtk_send("gtk_hscale_new_with_range 1 5 0.5")
    sliF = gtk_send("gtk_hscale_new_with_range 1 40 1")
    sliP = gtk_send("gtk_hscale_new_with_range -1.6 1.6 0.1")
    # and put them on the table.
    gtk_send("gtk_table_attach_defaults $tbl $sliA 4 9 1 2")
    gtk_send("gtk_table_attach_defaults $tbl $sliF 4 9 3 4")
    gtk_send("gtk_table_attach_defaults $tbl $sliP 4 9 5 6")
    # Now we need to actually display all the widgets we've created.
    gtk_send("gtk_widget_show_all $win")

    # endless loop; we only break out of it when the quit button is clicked
    while true
        # Up to this point, we have sent commands to gtk-server in order
        # to set up the GUI and display it. However, once the GUI is
        # created, gtk-server will send messages (events) to us whenever
        # the user clicks something on the GUI. In order to read these
        # events, we send gtk-server the message "gtk_server_callback wait".
        # So, if the user has clicked on a widget on the GUI, then
        # 'event' contains the widget's handle (ID number).
        event = gtk_send("gtk_server_callback wait")
        # The user clicked on the windows 'close' button.
        if event == win
            break
        end
        # The user clicked on the quit button.
        if event == but
            break
        end
        # The user clicked on the 'amplitude' slider. Now we need
        # to go to gtk-server again to ask for the new slider's value.
        if event == sliA
            # here we get the new value
            A_g = gtk_send("gtk_range_get_value $sliA")
            A = parse(Float32, A_g)
            # plot again with the new sine values
            P = doplots(t, A, f₀, ϕ, fs)
        end
        # Frequency slider.
        if event == sliF
            f₀_g = gtk_send("gtk_range_get_value $sliF")
            f₀ = parse(Float32, f₀_g)
            P = doplots(t, A, f₀, ϕ, fs)
        end
        # ϕ slider.
        if event == sliP
            ϕ_g = gtk_send("gtk_range_get_value $sliP")
            ϕ = parse(Float32, ϕ_g)
            P = doplots(t, A, f₀, ϕ, fs)
        end
    end

    # Clean up -- close all figures and tell gtk-server to quit.
    closeall()
    gtk_exit()
end
