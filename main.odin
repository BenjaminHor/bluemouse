package main

import "core:log"

import imgui "../odin-imgui/"
import "../odin-imgui/imgui_impl_glfw"
import "../odin-imgui/imgui_impl_opengl3"
import bm "src"

main :: proc() {
	context.logger = log.create_console_logger(opt = {.Level, .Terminal_Color})
	defer log.destroy_console_logger(context.logger)

	window := bm.init_window(800, 600, "BlueMouse")
	// Don't need to pass window handle here, framework keeps internal reference
	defer bm.shutdown_window()

	bm.set_vsync(true)
	bm.window_set_clear_color({17 / 255.0, 31 / 255.0, 18 / 255.0, 1})

	imgui.CHECKVERSION()
	imgui.CreateContext()
	defer imgui.DestroyContext()

	io := imgui.GetIO()
	io.ConfigFlags |= {.DockingEnable}

	imgui_impl_glfw.InitForOpenGL(window, true)
	defer imgui_impl_glfw.Shutdown()
	imgui_impl_opengl3.Init("#version 330")
	defer imgui_impl_opengl3.Shutdown()

	// Creating a static mesh
	vertices := []f32{-.5, -.5, 0, 0.5, -.5, 0, 0, .5, 0}
	triangle_mesh := bm.create_static_mesh(vertices)
	defer bm.destroy_mesh(&triangle_mesh)

	// Creating a shader program
	shader_program := bm.create_shader_program("res/vertex_shader.glsl", "res/frag_shader.glsl")
	defer bm.destroy_shader_program(shader_program)

	for !bm.window_should_close() {
		bm.poll_input()

		bm.begin_frame()
		{
			// Render pass
			bm.use_shader(shader_program)
			bm.render_static_mesh(triangle_mesh)

			// == IMGUI RELATED CODE ==
			imgui_impl_opengl3.NewFrame()
			imgui_impl_glfw.NewFrame()
			imgui.NewFrame()
			imgui.DockSpaceOverViewport({}, nil, {.PassthruCentralNode})

			// IMGUI calls here

			imgui.Render()
			imgui_impl_opengl3.RenderDrawData(imgui.GetDrawData())
		}
		bm.end_frame()
	}
}
