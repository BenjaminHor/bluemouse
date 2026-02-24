package bluemouse

import "core:log"
import "core:os"
import "core:strings"
import gl "vendor:OpenGL"

ShaderType :: enum u32 {
	VERTEX   = gl.VERTEX_SHADER,
	FRAGMENT = gl.FRAGMENT_SHADER,
}

compile_shader_from_file :: proc(type: ShaderType, path: string) -> u32 {
	shader := gl.CreateShader(u32(type))
	bytes, ok := os.read_entire_file(path)
	defer delete(bytes)
	if !ok do log.errorf("Could not read %v", path)

	src := strings.clone_to_cstring(string(bytes))
	defer delete(src)
	src_len := i32(len(bytes))
	gl.ShaderSource(shader, 1, &src, &src_len)
	gl.CompileShader(shader)

	success: i32
	gl.GetShaderiv(shader, gl.COMPILE_STATUS, &success)
	if success == 0 do log.errorf("Could not compile %v", path)

	return shader
}

create_shader_program :: proc(vShaderPath: string, fShaderPath: string) -> u32 {
	// Compile Shaders
	vertex_shader := compile_shader_from_file(.VERTEX, vShaderPath)
	fragment_shader := compile_shader_from_file(.FRAGMENT, fShaderPath)

	// Creating a shader program
	shader_program := gl.CreateProgram()
	gl.AttachShader(shader_program, vertex_shader)
	gl.AttachShader(shader_program, fragment_shader)
	gl.LinkProgram(shader_program)

	// Once linked, we can delete the shaders
	gl.DeleteShader(vertex_shader)
	gl.DeleteShader(fragment_shader)

	return shader_program
}

use_shader :: proc(program: u32) {
	if program != 0 do gl.UseProgram(program)
}

destroy_shader_program :: proc(program: u32) {
	if program != 0 do gl.DeleteProgram(program)
}

render_static_mesh :: proc(mesh: Mesh) {
	gl.BindVertexArray(mesh.VAO)
	gl.DrawArrays(gl.TRIANGLES, 0, i32(mesh.vertex_count))
}
