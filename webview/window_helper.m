#include "window_helper.h"
#include <string.h>

#if defined(__APPLE__)
#import <Cocoa/Cocoa.h>

void rad_window_set_always_on_top(void* window_handle, int on_top) {
    if (!window_handle) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSWindow* window = (NSWindow*)window_handle;
        if (on_top) {
            [window setLevel:NSFloatingWindowLevel];
        } else {
            [window setLevel:NSNormalWindowLevel];
        }
    });
}

void rad_window_toggle_fullscreen(void* window_handle) {
    if (!window_handle) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSWindow* window = (NSWindow*)window_handle;
        NSWindowStyleMask mask = [window styleMask];
        if (!(mask & NSWindowStyleMaskResizable)) {
            [window setStyleMask:(mask | NSWindowStyleMaskResizable)];
        }
        NSWindowCollectionBehavior cb = [window collectionBehavior];
        if (!(cb & NSWindowCollectionBehaviorFullScreenPrimary)) {
            [window setCollectionBehavior:(cb | NSWindowCollectionBehaviorFullScreenPrimary)];
        }
        [window toggleFullScreen:nil];
    });
}

void rad_window_set_fullscreen(void* window_handle, int fullscreen) {
    if (!window_handle) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSWindow* window = (NSWindow*)window_handle;
        BOOL is_fs = (([window styleMask] & NSWindowStyleMaskFullScreen) != 0);
        if ((fullscreen && !is_fs) || (!fullscreen && is_fs)) {
            NSWindowStyleMask mask = [window styleMask];
            if (!(mask & NSWindowStyleMaskResizable)) {
                [window setStyleMask:(mask | NSWindowStyleMaskResizable)];
            }
            NSWindowCollectionBehavior cb = [window collectionBehavior];
            if (!(cb & NSWindowCollectionBehaviorFullScreenPrimary)) {
                [window setCollectionBehavior:(cb | NSWindowCollectionBehaviorFullScreenPrimary)];
            }
            [window toggleFullScreen:nil];
        }
    });
}

void rad_window_minimize(void* window_handle) {
    if (!window_handle) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSWindow* window = (NSWindow*)window_handle;
        NSWindowStyleMask mask = [window styleMask];
        if (!(mask & NSWindowStyleMaskMiniaturizable)) {
            [window setStyleMask:(mask | NSWindowStyleMaskMiniaturizable)];
        }
        if (mask & NSWindowStyleMaskFullScreen) {
            [window toggleFullScreen:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [window miniaturize:nil];
            });
        } else {
            [window miniaturize:nil];
        }
    });
}

void rad_window_hide(void* window_handle) {
    (void)window_handle;
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSApp hide:nil];
    });
}

void rad_window_center(void* window_handle) {
    if (!window_handle) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSWindow* window = (NSWindow*)window_handle;
        [window center];
    });
}

void rad_window_set_position(void* window_handle, const char* preset) {
    if (!window_handle || !preset) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSWindow* window = (NSWindow*)window_handle;
        NSScreen* screen = [window screen];
        if (!screen) screen = [NSScreen mainScreen];
        if (!screen) return;

        NSRect screen_frame = [screen visibleFrame];
        NSRect win_frame = [window frame];

        CGFloat x = win_frame.origin.x;
        CGFloat y = win_frame.origin.y;

        if (strcmp(preset, "center") == 0) {
            x = screen_frame.origin.x + (screen_frame.size.width - win_frame.size.width) / 2.0;
            y = screen_frame.origin.y + (screen_frame.size.height - win_frame.size.height) / 2.0;
        } else if (strcmp(preset, "upper_left") == 0) {
            x = screen_frame.origin.x;
            y = screen_frame.origin.y + screen_frame.size.height - win_frame.size.height;
        } else if (strcmp(preset, "upper_right") == 0) {
            x = screen_frame.origin.x + screen_frame.size.width - win_frame.size.width;
            y = screen_frame.origin.y + screen_frame.size.height - win_frame.size.height;
        } else if (strcmp(preset, "top_center") == 0) {
            x = screen_frame.origin.x + (screen_frame.size.width - win_frame.size.width) / 2.0;
            y = screen_frame.origin.y + screen_frame.size.height - win_frame.size.height;
        } else if (strcmp(preset, "bottom_left") == 0) {
            x = screen_frame.origin.x;
            y = screen_frame.origin.y;
        } else if (strcmp(preset, "bottom_right") == 0) {
            x = screen_frame.origin.x + screen_frame.size.width - win_frame.size.width;
            y = screen_frame.origin.y;
        } else if (strcmp(preset, "bottom_center") == 0) {
            x = screen_frame.origin.x + (screen_frame.size.width - win_frame.size.width) / 2.0;
            y = screen_frame.origin.y;
        } else if (strcmp(preset, "center_left") == 0) {
            x = screen_frame.origin.x;
            y = screen_frame.origin.y + (screen_frame.size.height - win_frame.size.height) / 2.0;
        } else if (strcmp(preset, "center_right") == 0) {
            x = screen_frame.origin.x + screen_frame.size.width - win_frame.size.width;
            y = screen_frame.origin.y + (screen_frame.size.height - win_frame.size.height) / 2.0;
        }

        [window setFrameOrigin:NSMakePoint(x, y)];
    });
}

void rad_window_get_screen_size(int* out_width, int* out_height) {
    if (!out_width || !out_height) return;
    NSScreen* screen = [NSScreen mainScreen];
    if (screen) {
        NSRect frame = [screen frame];
        *out_width = (int)frame.size.width;
        *out_height = (int)frame.size.height;
    } else {
        *out_width = 1920;
        *out_height = 1080;
    }
}

static BOOL s_shortcuts_installed = NO;

void rad_window_init_shortcuts(void) {
    if (s_shortcuts_installed) return;
    s_shortcuts_installed = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:^NSEvent *(NSEvent *event) {
            NSEventModifierFlags flags = [event modifierFlags] & NSEventModifierFlagDeviceIndependentFlagsMask;
            if (flags == NSEventModifierFlagCommand) {
                NSString *chars = [[event charactersIgnoringModifiers] lowercaseString];
                if ([chars isEqualToString:@"q"]) {
                    [NSApp terminate:nil];
                    exit(0);
                    return nil;
                } else if ([chars isEqualToString:@"w"]) {
                    NSWindow *keyWindow = [NSApp keyWindow];
                    if (keyWindow) {
                        [keyWindow performClose:nil];
                    }
                    return nil;
                }
            }
            return event;
        }];
    });
}

void rad_window_quit(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSApp terminate:nil];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        exit(0);
    });
}

#elif defined(_WIN32)
#include <windows.h>

void rad_window_set_always_on_top(void* window_handle, int on_top) {
    if (!window_handle) return;
    HWND hwnd = (HWND)window_handle;
    HWND insertAfter = on_top ? HWND_TOPMOST : HWND_NOTOPMOST;
    SetWindowPos(hwnd, insertAfter, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE);
}

void rad_window_toggle_fullscreen(void* window_handle) {
    if (!window_handle) return;
    HWND hwnd = (HWND)window_handle;
    DWORD style = GetWindowLong(hwnd, GWL_STYLE);
    if (style & WS_OVERLAPPEDWINDOW) {
        MONITORINFO mi = { sizeof(mi) };
        if (GetMonitorInfo(MonitorFromWindow(hwnd, MONITOR_DEFAULTTOPRIMARY), &mi)) {
            SetWindowLong(hwnd, GWL_STYLE, style & ~WS_OVERLAPPEDWINDOW);
            SetWindowPos(hwnd, HWND_TOP, mi.rcMonitor.left, mi.rcMonitor.top,
                         mi.rcMonitor.right - mi.rcMonitor.left,
                         mi.rcMonitor.bottom - mi.rcMonitor.top,
                         SWP_NOOWNERZORDER | SWP_FRAMECHANGED);
        }
    } else {
        SetWindowLong(hwnd, GWL_STYLE, style | WS_OVERLAPPEDWINDOW);
        SetWindowPos(hwnd, NULL, 0, 0, 0, 0,
                     SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_FRAMECHANGED);
    }
}

void rad_window_set_fullscreen(void* window_handle, int fullscreen) {
    if (!window_handle) return;
    HWND hwnd = (HWND)window_handle;
    DWORD style = GetWindowLong(hwnd, GWL_STYLE);
    int is_fs = !(style & WS_OVERLAPPEDWINDOW);
    if ((fullscreen && !is_fs) || (!fullscreen && is_fs)) {
        rad_window_toggle_fullscreen(window_handle);
    }
}

void rad_window_minimize(void* window_handle) {
    if (!window_handle) return;
    ShowWindow((HWND)window_handle, SW_MINIMIZE);
}

void rad_window_hide(void* window_handle) {
    if (!window_handle) return;
    ShowWindow((HWND)window_handle, SW_HIDE);
}

void rad_window_center(void* window_handle) {
    if (!window_handle) return;
    HWND hwnd = (HWND)window_handle;
    RECT rc;
    GetWindowRect(hwnd, &rc);
    int win_w = rc.right - rc.left;
    int win_h = rc.bottom - rc.top;
    int scr_w = GetSystemMetrics(SM_CXSCREEN);
    int scr_h = GetSystemMetrics(SM_CYSCREEN);
    int x = (scr_w - win_w) / 2;
    int y = (scr_h - win_h) / 2;
    SetWindowPos(hwnd, NULL, x, y, 0, 0, SWP_NOSIZE | SWP_NOZORDER);
}

void rad_window_set_position(void* window_handle, const char* preset) {
    if (!window_handle || !preset) return;
    HWND hwnd = (HWND)window_handle;
    RECT rc;
    GetWindowRect(hwnd, &rc);
    int win_w = rc.right - rc.left;
    int win_h = rc.bottom - rc.top;
    int scr_w = GetSystemMetrics(SM_CXSCREEN);
    int scr_h = GetSystemMetrics(SM_CYSCREEN);
    int x = rc.left, y = rc.top;

    if (strcmp(preset, "center") == 0) {
        x = (scr_w - win_w) / 2;
        y = (scr_h - win_h) / 2;
    } else if (strcmp(preset, "upper_left") == 0) {
        x = 0; y = 0;
    } else if (strcmp(preset, "upper_right") == 0) {
        x = scr_w - win_w; y = 0;
    } else if (strcmp(preset, "top_center") == 0) {
        x = (scr_w - win_w) / 2; y = 0;
    } else if (strcmp(preset, "bottom_left") == 0) {
        x = 0; y = scr_h - win_h;
    } else if (strcmp(preset, "bottom_right") == 0) {
        x = scr_w - win_w; y = scr_h - win_h;
    } else if (strcmp(preset, "bottom_center") == 0) {
        x = (scr_w - win_w) / 2; y = scr_h - win_h;
    } else if (strcmp(preset, "center_left") == 0) {
        x = 0; y = (scr_h - win_h) / 2;
    } else if (strcmp(preset, "center_right") == 0) {
        x = scr_w - win_w; y = (scr_h - win_h) / 2;
    }

    SetWindowPos(hwnd, NULL, x, y, 0, 0, SWP_NOSIZE | SWP_NOZORDER);
}

void rad_window_get_screen_size(int* out_width, int* out_height) {
    if (!out_width || !out_height) return;
    *out_width = GetSystemMetrics(SM_CXSCREEN);
    *out_height = GetSystemMetrics(SM_CYSCREEN);
}

void rad_window_init_shortcuts(void) {}

void rad_window_quit(void) {
    PostQuitMessage(0);
    ExitProcess(0);
}

#elif defined(__linux__)
#include <gtk/gtk.h>

void rad_window_set_always_on_top(void* window_handle, int on_top) {
    if (!window_handle) return;
    gtk_window_set_keep_above(GTK_WINDOW(window_handle), on_top ? TRUE : FALSE);
}

void rad_window_toggle_fullscreen(void* window_handle) {
    if (!window_handle) return;
    GtkWindow* win = GTK_WINDOW(window_handle);
    GdkWindow* gdk_win = gtk_widget_get_window(GTK_WIDGET(win));
    if (!gdk_win) return;
    GdkWindowState state = gdk_window_get_state(gdk_win);
    if (state & GDK_WINDOW_STATE_FULLSCREEN) {
        gtk_window_unfullscreen(win);
    } else {
        gtk_window_fullscreen(win);
    }
}

void rad_window_set_fullscreen(void* window_handle, int fullscreen) {
    if (!window_handle) return;
    GtkWindow* win = GTK_WINDOW(window_handle);
    if (fullscreen) {
        gtk_window_fullscreen(win);
    } else {
        gtk_window_unfullscreen(win);
    }
}

void rad_window_minimize(void* window_handle) {
    if (!window_handle) return;
    gtk_window_iconify(GTK_WINDOW(window_handle));
}

void rad_window_hide(void* window_handle) {
    if (!window_handle) return;
    gtk_widget_hide(GTK_WIDGET(window_handle));
}

void rad_window_center(void* window_handle) {
    if (!window_handle) return;
    gtk_window_set_position(GTK_WINDOW(window_handle), GTK_WIN_POS_CENTER);
}

void rad_window_set_position(void* window_handle, const char* preset) {
    if (!window_handle || !preset) return;
    GtkWindow* win = GTK_WINDOW(window_handle);

    int scr_w = 1920, scr_h = 1080;
    rad_window_get_screen_size(&scr_w, &scr_h);

    int win_w = 800, win_h = 600;
    gtk_window_get_size(win, &win_w, &win_h);

    int x = (scr_w - win_w) / 2;
    int y = (scr_h - win_h) / 2;

    if (strcmp(preset, "upper_left") == 0) {
        x = 0; y = 0;
    } else if (strcmp(preset, "upper_right") == 0) {
        x = scr_w - win_w; y = 0;
    } else if (strcmp(preset, "top_center") == 0) {
        x = (scr_w - win_w) / 2; y = 0;
    } else if (strcmp(preset, "bottom_left") == 0) {
        x = 0; y = scr_h - win_h;
    } else if (strcmp(preset, "bottom_right") == 0) {
        x = scr_w - win_w; y = scr_h - win_h;
    } else if (strcmp(preset, "bottom_center") == 0) {
        x = (scr_w - win_w) / 2; y = scr_h - win_h;
    } else if (strcmp(preset, "center_left") == 0) {
        x = 0; y = (scr_h - win_h) / 2;
    } else if (strcmp(preset, "center_right") == 0) {
        x = scr_w - win_w; y = (scr_h - win_h) / 2;
    }

    gtk_window_move(win, x, y);
}

void rad_window_get_screen_size(int* out_width, int* out_height) {
    if (!out_width || !out_height) return;
    GdkScreen* screen = gdk_screen_get_default();
    if (screen) {
        *out_width = gdk_screen_get_width(screen);
        *out_height = gdk_screen_get_height(screen);
    } else {
        *out_width = 1920;
        *out_height = 1080;
    }
}

void rad_window_init_shortcuts(void) {}

void rad_window_quit(void) {
    exit(0);
}

#else

void rad_window_set_always_on_top(void* window_handle, int on_top) { (void)window_handle; (void)on_top; }
void rad_window_toggle_fullscreen(void* window_handle) { (void)window_handle; }
void rad_window_set_fullscreen(void* window_handle, int fullscreen) { (void)window_handle; (void)fullscreen; }
void rad_window_minimize(void* window_handle) { (void)window_handle; }
void rad_window_hide(void* window_handle) { (void)window_handle; }
void rad_window_center(void* window_handle) { (void)window_handle; }
void rad_window_set_position(void* window_handle, const char* preset) { (void)window_handle; (void)preset; }
void rad_window_get_screen_size(int* out_width, int* out_height) {
    if (out_width) *out_width = 1920;
    if (out_height) *out_height = 1080;
}
void rad_window_init_shortcuts(void) {}
void rad_window_quit(void) { exit(0); }

#endif
