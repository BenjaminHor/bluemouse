package bluemouse

import gl "vendor:OpenGL"

Mesh :: struct {
	VAO, VBO, EBO: u32,
	vertex_count:  int,
	index_count:   int,
	indexed:       bool, // Does this mesh leverage an index array or not
}


create_static_mesh :: proc(vertices: []f32) -> Mesh {
	mesh := Mesh{}
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

	mesh.VAO = vao
	mesh.VBO = vbo
	mesh.vertex_count = len(vertices) / 3

	return mesh
}
