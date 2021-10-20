resource "docker_container" "experimental-alpine" {
	image       = docker_image.alpine.latest
	name        = "experimental-alpine"
	command     = [ "tail", "-f", "/dev/null" ]
	memory      = 250
	memory_swap = 500
	must_run    = true
}