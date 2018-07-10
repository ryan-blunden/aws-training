output "instance_id" {
  value = "${aws_instance.this.*.id}"
}

output "instance_name" {
  value = "${aws_instance.this.*.tags.Name}"
}

output "instance_public_ip" {
  value = "${aws_instance.this.*.public_ip}"
}

output "instance_private_ip" {
  value = "${aws_instance.this.*.private_ip}"
}
