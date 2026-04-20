resource "null_resource" "wait_for_lb" {
  triggers = {
    gateway_release = helm_release.envoy_gw_api.metadata.revision
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws eks update-kubeconfig --region ${var.aws_region} --name ${var.cluster_name}

      echo "Waiting for AWS to provision Load Balancer..."
      timeout 600 bash -c '
      until kubectl get svc -n ${kubernetes_namespace_v1.envoy_gw_api.metadata[0].name} \
        -l gateway.envoyproxy.io/owning-gateway-name=buried-marks-gateway \
        -o jsonpath="{.items[0].status.loadBalancer.ingress[0].hostname}" \
        | grep -q ".elb.amazonaws.com"; do
        echo "Still waiting for ELB..."
        sleep 10
      done
      '
      echo "ELB is successfully provisioned!"
    EOT
  }

  depends_on = [helm_release.envoy_gw_api]
}

data "kubernetes_resources" "envoy_lb" {
  api_version    = "v1"
  kind           = "Service"
  namespace      = kubernetes_namespace_v1.envoy_gw_api.metadata[0].name
  label_selector = "gateway.envoyproxy.io/owning-gateway-name=buried-marks-gateway"
  depends_on     = [null_resource.wait_for_lb]
}

resource "aws_route53_record" "marks_custom_domain" {
  zone_id = var.zone_id
  name    = "marks.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300
  # records = [data.kubernetes_resources.envoy_lb.objects[0].status.loadBalancer.ingress[0].hostname]
  records = [
    try(data.kubernetes_resources.envoy_lb.objects[0].status.loadBalancer.ingress[0].hostname, "")
  ]
}
