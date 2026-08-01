variable "sg_names" {
  type = list(string)
  default = ["frontend","backend","database"]
}
variable "project_name" {
  default = "ai-hmis"
}
variable "env" {
  default = "dev"
}
