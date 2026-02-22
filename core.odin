package bluemouse

import "core:fmt"
import gl "vendor:OpenGL"
import "vendor:glfw"

Core :: struct {
	window: Window,
	input:  Input,
}

CORE: Core

Window :: struct {
	handle: glfw.WindowHandle,
}

init_window :: proc(width: int, height: int, title: string) -> glfw.WindowHandle {
	assert(cast(bool)glfw.Init())

	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
	glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, 1)

	window := glfw.CreateWindow(i32(width), i32(height), fmt.caprintf(title), nil, nil)
	assert(window != nil)

	CORE.window.handle = window

	glfw.MakeContextCurrent(window)

	gl.load_up_to(3, 3, proc(p: rawptr, name: cstring) {
		(cast(^rawptr)p)^ = glfw.GetProcAddress(name)
	})

	return window
}

destroy_window :: proc() {
	glfw.Terminate()
	// NOTE: calling delete out of habit but not needed here
	// since this should be cleaned up on program exit
	delete(glfw.GetWindowTitle(CORE.window.handle))
	glfw.DestroyWindow(CORE.window.handle)
}

// Must be called after init_window
// GLFW needs a current window context
set_vsync :: proc(enabled: bool) {
	if enabled do glfw.SwapInterval(1)
	else do glfw.SwapInterval(0)
}

window_should_close :: proc() -> bool {
	return bool(glfw.WindowShouldClose(CORE.window.handle))
}

clear_background :: proc(color: [4]f32) {
	// Clearing display right before rendering frame
	display_w, display_h := glfw.GetFramebufferSize(CORE.window.handle)
	gl.Viewport(0, 0, display_w, display_h)
	gl.ClearColor(color.r, color.g, color.b, color.a)
	gl.Clear(gl.COLOR_BUFFER_BIT)
}
