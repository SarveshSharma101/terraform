output "op" {
    value = {
        vpc = module.vpc.op
        cloud-nat = module.cloud-nat.op
        # mig = module.mig.op
        loadbalancer = module.loadbalancer.op
        neg = module.NEG.op
    }
}