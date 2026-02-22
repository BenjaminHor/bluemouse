package bluemouse

import imgui "../odin-imgui/"
import "../odin-imgui/imgui_impl_glfw"
import "../odin-imgui/imgui_impl_opengl3"
import "core:fmt"
import "core:log"
import gl "vendor:OpenGL"
import "vendor:glfw"

main :: proc() {
	context.logger = log.create_console_logger()
	defer log.destroy_console_logger(context.logger)

	window := init_window(800, 600, "BlueMouse")
	// Don't need to pass window handle here, framework keeps internal reference
	defer destroy_window()

	set_vsync(true)

	imgui.CHECKVERSION()
	imgui.CreateContext()
	defer imgui.DestroyContext()

	io := imgui.GetIO()
	io.ConfigFlags |= {.DockingEnable}

	imgui_impl_glfw.InitForOpenGL(window, true)
	defer imgui_impl_glfw.Shutdown()
	imgui_impl_opengl3.Init("#version 150")
	defer imgui_impl_opengl3.Shutdown()

	for !window_should_close() {
		poll_input()

		// Clearing display right before rendering frame
		clear_background({0, 0.5, 0.8, 1})

		// Render pass


		// == IMGUI RELATED CODE ==
		imgui_impl_opengl3.NewFrame()
		imgui_impl_glfw.NewFrame()
		imgui.NewFrame()
		imgui.DockSpaceOverViewport({}, nil, {.PassthruCentralNode})

		// IMGUI calls here

		imgui.Render()
		imgui_impl_opengl3.RenderDrawData(imgui.GetDrawData())

		glfw.SwapBuffers(window)
	}
}
