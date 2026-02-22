package main

import "core:fmt"
import "core:log"
import "core:os"
import "core:strings"
import "core:time"
import gl "vendor:OpenGL"
import "vendor:glfw"

import imgui "../odin-imgui/"
import "../odin-imgui/imgui_impl_glfw"
import "../odin-imgui/imgui_impl_opengl3"
import bm "src"

main :: proc() {
	context.logger = log.create_console_logger()
	defer log.destroy_console_logger(context.logger)

	window := bm.init_window(800, 600, "BlueMouse")
	// Don't need to pass window handle here, framework keeps internal reference
	defer bm.destroy_window()

	bm.set_vsync(true)

	imgui.CHECKVERSION()
	imgui.CreateContext()
	defer imgui.DestroyContext()

	io := imgui.GetIO()
	io.ConfigFlags |= {.DockingEnable}

	imgui_impl_glfw.InitForOpenGL(window, true)
	defer imgui_impl_glfw.Shutdown()
	imgui_impl_opengl3.Init("#version 150")
	defer imgui_impl_opengl3.Shutdown()


	vertices := []f32{-.5, -.5, 0, 0.5, -.5, 0, 0, .5, 0}

	// Creating vertex array object
	vao: u32
	gl.GenVertexArrays(1, &vao)
	gl.BindVertexArray(vao)

	// Creating a vertex buffer object
	vbo: u32
	gl.GenBuffers(1, &vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)

	// Copy vertex data into currently bound buffer
	size := len(vertices) * size_of(f32)
	gl.BufferData(gl.ARRAY_BUFFER, size, raw_data(vertices), gl.STATIC_DRAW)

	// Set vertex attribute pointers
	gl.VertexAttribPointer(0, 3, gl.FLOAT, false, 3 * size_of(f32), 0)
	gl.EnableVertexAttribArray(0)

	// Compile Vertex Shader
	vertex_shader := gl.CreateShader(gl.VERTEX_SHADER)
	bytes, ok := os.read_entire_file("res/vertex_shader.glsl")
	if !ok do log.error("Could not read vertex_shader.glsl")

	src := strings.clone_to_cstring(string(bytes))
	src_len := i32(len(bytes))
	gl.ShaderSource(vertex_shader, 1, &src, &src_len)
	gl.CompileShader(vertex_shader)

	// Cleanup
	delete(bytes)
	delete(src)

	success: i32
	gl.GetShaderiv(vertex_shader, gl.COMPILE_STATUS, &success)
	if success == 0 do log.error("Could not compile vertex_shader.glsl")

	// Compile Fragment Shader
	fragment_shader := gl.CreateShader(gl.FRAGMENT_SHADER)
	bytes, ok = os.read_entire_file("res/frag_shader.glsl")
	if !ok do log.error("Could not read frag_shader.glsl")

	src = strings.clone_to_cstring(string(bytes))
	src_len = i32(len(bytes))
	gl.ShaderSource(fragment_shader, 1, &src, &src_len)
	gl.CompileShader(fragment_shader)

	// Cleanup
	delete(bytes)
	delete(src)

	gl.GetShaderiv(vertex_shader, gl.COMPILE_STATUS, &success)
	if success == 0 do log.error("Could not compile frag_shader.glsl")

	// Creating a shader program
	shader_program := gl.CreateProgram()
	gl.AttachShader(shader_program, vertex_shader)
	gl.AttachShader(shader_program, fragment_shader)
	gl.LinkProgram(shader_program)

	// Once linked, we can delete the shaders
	gl.DeleteShader(vertex_shader)
	gl.DeleteShader(fragment_shader)


	for !bm.window_should_close() {
		bm.poll_input()

		// Clearing display right before rendering frame
		bm.clear_background({17 / 255.0, 31 / 255.0, 18 / 255.0, 1})

		// Render pass
		gl.UseProgram(shader_program)
		gl.BindVertexArray(vao)
		gl.DrawArrays(gl.TRIANGLES, 0, 3)

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
