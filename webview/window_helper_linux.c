#include "window_helper.h"
#include <gtk/gtk.h>
#include <string.h>

typedef enum {
    RAD_WINDOW_KEEP_ABOVE,
    RAD_WINDOW_TOGGLE_FULLSCREEN,
    RAD_WINDOW_SET_FULLSCREEN,
    RAD_WINDOW_MINIMIZE,
    RAD_WINDOW_HIDE,
    RAD_WINDOW_CENTER,
    RAD_WINDOW_SET_POSITION
} RadWindowAction;

typedef struct {
    GtkWindow* window;
    RadWindowAction action;
    int value;
    char preset[32];
} RadWindowActionRequest;

static GtkWindow* rad_gtk_window(void* window_handle) {
    if (window_handle == NULL || !GTK_IS_WINDOW(window_handle)) {
        return NULL;
    }
    return GTK_WINDOW(window_handle);
}

static gboolean rad_window_is_fullscreen(GtkWindow* window) {
    GdkWindow* gdk_window = gtk_widget_get_window(GTK_WIDGET(window));
    return gdk_window != NULL && (gdk_window_get_state(gdk_window) & GDK_WINDOW_STATE_FULLSCREEN) != 0;
}

static void rad_monitor_geometry(GtkWindow* window, GdkRectangle* geometry) {
    GdkScreen* screen = gtk_window_get_screen(window);
    gint monitor = gdk_screen_get_monitor_at_window(screen, gtk_widget_get_window(GTK_WIDGET(window)));
    if (monitor < 0) {
        monitor = 0;
    }
    gdk_screen_get_monitor_workarea(screen, monitor, geometry);
}

static void rad_move_to_preset(GtkWindow* window, const char* preset);

static gboolean rad_move_after_unfullscreen(gpointer data) {
    RadWindowActionRequest* request = data;
    if (GTK_IS_WINDOW(request->window)) {
        rad_move_to_preset(request->window, request->preset);
        gtk_window_present(request->window);
        g_object_unref(request->window);
    }
    g_free(request);
    return G_SOURCE_REMOVE;
}

static void rad_move_to_preset(GtkWindow* window, const char* preset) {
    GdkRectangle workarea;
    gint width = 0;
    gint height = 0;
    gint x = 0;
    gint y = 0;
    gtk_window_get_size(window, &width, &height);
    rad_monitor_geometry(window, &workarea);

    x = workarea.x + (workarea.width - width) / 2;
    y = workarea.y + (workarea.height - height) / 2;
    if (strcmp(preset, "upper_left") == 0 || strcmp(preset, "center_left") == 0 || strcmp(preset, "bottom_left") == 0) {
        x = workarea.x;
    } else if (strcmp(preset, "upper_right") == 0 || strcmp(preset, "center_right") == 0 || strcmp(preset, "bottom_right") == 0) {
        x = workarea.x + workarea.width - width;
    }
    if (strcmp(preset, "upper_left") == 0 || strcmp(preset, "top_center") == 0 || strcmp(preset, "upper_right") == 0) {
        y = workarea.y;
    } else if (strcmp(preset, "bottom_left") == 0 || strcmp(preset, "bottom_center") == 0 || strcmp(preset, "bottom_right") == 0) {
        y = workarea.y + workarea.height - height;
    }
    gtk_window_move(window, x, y);
}

static gboolean rad_apply_window_action(gpointer data) {
    RadWindowActionRequest* request = data;
    GtkWindow* window = request->window;
    if (GTK_IS_WINDOW(window)) {
        switch (request->action) {
            case RAD_WINDOW_KEEP_ABOVE:
                gtk_window_set_keep_above(window, request->value != 0);
                gtk_window_present(window);
                break;
            case RAD_WINDOW_TOGGLE_FULLSCREEN:
                if (rad_window_is_fullscreen(window)) {
                    gtk_window_unfullscreen(window);
                } else {
                    gtk_window_fullscreen(window);
                }
                break;
            case RAD_WINDOW_SET_FULLSCREEN:
                if (rad_window_is_fullscreen(window) != (request->value != 0)) {
                    if (request->value != 0) {
                        gtk_window_fullscreen(window);
                    } else {
                        gtk_window_unfullscreen(window);
                    }
                }
                break;
            case RAD_WINDOW_MINIMIZE:
                gtk_window_iconify(window);
                break;
            case RAD_WINDOW_HIDE:
                gtk_widget_hide(GTK_WIDGET(window));
                break;
            case RAD_WINDOW_CENTER:
                gtk_window_set_position(window, GTK_WIN_POS_CENTER);
                break;
            case RAD_WINDOW_SET_POSITION:
                if (rad_window_is_fullscreen(window)) {
                    gtk_window_unfullscreen(window);
                    g_timeout_add_full(G_PRIORITY_DEFAULT, 150, rad_move_after_unfullscreen, request, NULL);
                    return G_SOURCE_REMOVE;
                }
                rad_move_to_preset(window, request->preset);
                gtk_window_present(window);
                break;
        }
        g_object_unref(window);
    }
    g_free(request);
    return G_SOURCE_REMOVE;
}

static void rad_queue_window_action(void* window_handle, RadWindowAction action, int value, const char* preset) {
    GtkWindow* window = rad_gtk_window(window_handle);
    if (window == NULL) {
        return;
    }
    RadWindowActionRequest* request = g_new0(RadWindowActionRequest, 1);
    request->window = GTK_WINDOW(g_object_ref(window));
    request->action = action;
    request->value = value;
    if (preset != NULL) {
        g_strlcpy(request->preset, preset, sizeof(request->preset));
    }
    g_main_context_invoke(NULL, rad_apply_window_action, request);
}

void rad_window_set_always_on_top(void* window_handle, int on_top) {
    rad_queue_window_action(window_handle, RAD_WINDOW_KEEP_ABOVE, on_top, NULL);
}

void rad_window_toggle_fullscreen(void* window_handle) {
    rad_queue_window_action(window_handle, RAD_WINDOW_TOGGLE_FULLSCREEN, 0, NULL);
}

void rad_window_set_fullscreen(void* window_handle, int fullscreen) {
    rad_queue_window_action(window_handle, RAD_WINDOW_SET_FULLSCREEN, fullscreen, NULL);
}

void rad_window_minimize(void* window_handle) {
    rad_queue_window_action(window_handle, RAD_WINDOW_MINIMIZE, 0, NULL);
}

void rad_window_hide(void* window_handle) {
    rad_queue_window_action(window_handle, RAD_WINDOW_HIDE, 0, NULL);
}

void rad_window_center(void* window_handle) {
    rad_queue_window_action(window_handle, RAD_WINDOW_CENTER, 0, NULL);
}

void rad_window_set_position(void* window_handle, const char* preset) {
    rad_queue_window_action(window_handle, RAD_WINDOW_SET_POSITION, 0, preset);
}

void rad_window_get_screen_size(int* out_width, int* out_height) {
    GdkDisplay* display = gdk_display_get_default();
    GdkMonitor* monitor = display == NULL ? NULL : gdk_display_get_primary_monitor(display);
    GdkRectangle geometry = {0, 0, 1920, 1080};
    if (monitor != NULL) {
        gdk_monitor_get_geometry(monitor, &geometry);
    }
    if (out_width != NULL) {
        *out_width = geometry.width;
    }
    if (out_height != NULL) {
        *out_height = geometry.height;
    }
}

void rad_window_init_shortcuts(void) {
}

static gboolean rad_quit_main_loop(gpointer data) {
    (void)data;
    gtk_main_quit();
    return G_SOURCE_REMOVE;
}

void rad_window_quit(void) {
    g_main_context_invoke(NULL, rad_quit_main_loop, NULL);
}
