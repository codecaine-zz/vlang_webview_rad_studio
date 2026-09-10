#ifndef RAD_WINDOW_HELPER_H
#define RAD_WINDOW_HELPER_H

#ifdef __cplusplus
extern "C" {
#endif

void rad_window_set_always_on_top(void* window_handle, int on_top);
void rad_window_toggle_fullscreen(void* window_handle);
void rad_window_set_fullscreen(void* window_handle, int fullscreen);
void rad_window_minimize(void* window_handle);
void rad_window_hide(void* window_handle);
void rad_window_center(void* window_handle);
void rad_window_set_position(void* window_handle, const char* preset);
void rad_window_get_screen_size(int* out_width, int* out_height);
void rad_window_init_shortcuts(void);
void rad_window_quit(void);

#ifdef __cplusplus
}
#endif

#endif // RAD_WINDOW_HELPER_H
