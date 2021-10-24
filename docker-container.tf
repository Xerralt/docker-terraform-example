resource "docker_container" "nginx-example" {
	image       = docker_image.nginx.latest
	name        = "nginx-example"
	memory      = 250
	memory_swap = 500
	must_run    = true
	
	ports {
		internal = 80
		external = 8000
	}
}
